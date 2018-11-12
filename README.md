## xor game
大致上就是判断flag长度，然后根据字频直接爆破flag，exp如下
```
# -*- coding:utf-8 -*-
import base64
import itertools
import string
from Crypto.Util.strxor import strxor_c, strxor


freqs = {
    "a": 8.167,
    "b": 1.492,
    "c": 2.782,
    "d": 4.253,
    "e": 12.702,
    "f": 2.228,
    "g": 2.015,
    "h": 6.094,
    "i": 6.966,
    "j": 0.153,
    "k": 0.772,
    "l": 4.025,
    "m": 2.406,
    "n": 6.749,
    "o": 7.507,
    "p": 1.929,
    "q": 0.095,
    "r": 5.987,
    "s": 6.327,
    "t": 9.056,
    "u": 2.758,
    "v": 0.978,
    "w": 2.360,
    "x": 0.150,
    "y": 1.974,
    "z": 0.074,
    " ": 20.0
}


def score(s):
    counts = {}
    for i in string.ascii_lowercase + ' ':
        counts[i] = s.count(i)

    score = 0.0
    for i in s:
        i = i.lower()
        if i in freqs:
            score += freqs[i] * counts[i]
    return score/len(s)


def break_single_xor(data):
    def key(s):
        return score(s[1])
    return max([(i, strxor_c(data, i)) for i in range(256)], key=key)


def get_hamming_distance(x, y):
    return sum([bin(ord(x[i]) ^ ord(y[i])).count('1') for i in range(len(x))])


def get_edit_distance(data, k):
    blocks = [data[i:i+k] for i in range(0, len(data), k)][0:4]
    pairs = list(itertools.combinations(blocks, 2))
    scores = [get_hamming_distance(p[0], p[1])/float(k) for p in pairs][0:6]
    return sum(scores) / len(scores)


def break_repeat_xor(data, length):
    blocks = [data[i:i+length] for i in range(0, len(data), length)]
    transposedBlocks = list(itertools.izip_longest(*blocks, fillvalue=0))
    key = [break_single_xor(''.join([str(n) for n in x]))[0] for x in transposedBlocks]
    return ''.join([chr(x) for x in key])


def repeat_key_xor(data, key):
    key = (key * (len(data) / len(key) + 1))[:len(data)]
    return strxor(data, key)


data = base64.b64decode(open('cipher.txt', 'r').read().replace('\n', ''))

k = min(range(2, 41), key=lambda k: get_edit_distance(data, k))
print "keylength: {}".format(str(k))
key = break_repeat_xor(data, k)
print "key: {}".format(str(key))
print "poem: {}".format(repeat_key_xor(data, key))
```
后来我发现，什么都不用判断。只要能获取一小部分对的flag，然后异或密文，那不正确的明文直接查这首诗就好了。=。=
## xor?rsa
很单纯的short pad attack
```
def composite_gcd(g1,g2):
	return g1.monic() if g2 == 0 else composite_gcd(g2, g1 % g2)

def franklin_reiter(c1, c2, N, r, e=3):
	P.<x> = PolynomialRing(Zmod(N))
	equations = [x ^ e - c1, (x + r) ^ e - c2]
	g1, g2 = equations
	print(type(g1))
	return -composite_gcd(g1,g2).coefficients()[0]

def short_pad_attack(c1, c2, e, n, nbits, kbits):
    PRxy.<x,y> = PolynomialRing(Zmod(n))
    PRx.<xn> = PolynomialRing(Zmod(n))
    PRZZ.<xz,yz> = PolynomialRing(Zmod(n))
    g1 = x^e - c1
    g2 = (x+y)^e - c2
    q1 = g1.change_ring(PRZZ)
    q2 = g2.change_ring(PRZZ)
    h = q2.resultant(q1)
    h = h.univariate_polynomial()
    h = h.change_ring(PRx).subs(y=xn)
    h = h.monic()
    r = h.small_roots(X=2^kbits, beta=0.5)[0]
    m1 = franklin_reiter(c1, c2, n, r, e)
    return m1, m1 + r


e = 5
n = ...
c1 = ...
c2 = ...

m1, m2 = short_pad_attack(c1, c2, e, n, 2048, 40)
print m1
print m2
```
## bestrong
https://github.com/LuckyC4t/HCTF-2018-bestrong

