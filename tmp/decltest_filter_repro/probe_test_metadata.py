import struct
import subprocess
import sys

path = sys.argv[1]
p = subprocess.Popen([path, '--listen=-'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def read_exact(n: int) -> bytes:
    data = b''
    while len(data) < n:
        chunk = p.stdout.read(n - len(data))
        if not chunk:
            raise RuntimeError(f'eof after {len(data)} bytes')
        data += chunk
    return data

hdr = read_exact(8)
tag, blen = struct.unpack('<II', hdr)
body = read_exact(blen)
print('first_tag', tag, 'zig_version', body.decode())

p.stdin.write(struct.pack('<II', 4, 0))
p.stdin.flush()

while True:
    hdr = read_exact(8)
    tag, blen = struct.unpack('<II', hdr)
    body = read_exact(blen)
    if tag != 3:
        print('msg_tag', tag, 'len', blen)
        continue

    string_bytes_len, tests_len = struct.unpack('<II', body[:8])
    rest = body[8:]
    names = struct.unpack('<' + 'I' * tests_len, rest[: 4 * tests_len])
    rest = rest[4 * tests_len :]
    _panics = struct.unpack('<' + 'I' * tests_len, rest[: 4 * tests_len])
    strings = rest[4 * tests_len : 4 * tests_len + string_bytes_len]
    print('tests_len', tests_len)
    for i, off in enumerate(names):
        end = strings.index(b'\0', off)
        name = strings[off:end].decode()
        print(i, name)
    break

p.stdin.write(struct.pack('<II', 0, 0))
p.stdin.flush()
_stdout, stderr = p.communicate(timeout=5)
if stderr:
    print('stderr:', stderr.decode())
