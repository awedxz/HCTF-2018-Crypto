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