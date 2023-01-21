script;
use basic_storage_abi::{BasicStorage, Quad};

fn main() -> u64 {
    let addr = abi(BasicStorage, 0x5bbe601ecf0e2146ccbe458437af08261a58c9033b15cc9606a4e3835d28be9c);
    let key = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    let value = 4242;

    /* Simple test using `store` and `get` from `std::storage */
    addr.store_u64(key, value);
    let res = addr.get_u64(key);
    assert(res == value);

    /* Test single word storage intrinsics */
    let key = 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    addr.intrinsic_store_word(key, value);
    let res = addr.intrinsic_load_word(key);
    assert(res == value);

    /* Test quad storage intrinsics with a single storage slot */
    let key = 0x11ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    let q = Quad {
        v1: 1,
        v2: 2,
        v3: 4,
        v4: 100,
    };
    let mut values = Vec::new();
    values.push(q);
    addr.intrinsic_store_quad(key, values);
    let r = addr.intrinsic_load_quad(key, 1).get(0).unwrap();
    assert(q.v1 == r.v1 && q.v2 == r.v2 && q.v3 == r.v3 && q.v4 == r.v4);

    /* Test quad storage intrinsics with multiple storage slots */
    let key = 0x11ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    let q0 = Quad {
        v1: 1,
        v2: 2,
        v3: 4,
        v4: 100,
    };
    let q1 = Quad {
        v1: 2,
        v2: 3,
        v3: 5,
        v4: 101,
    };
    let mut values = Vec::new();
    values.push(q0);
    values.push(q1);
    addr.intrinsic_store_quad(key, values);
    let r = addr.intrinsic_load_quad(key, values.len());
    let r0 = r.get(0).unwrap();
    let r1 = r.get(1).unwrap();
    assert(q0.v1 == r0.v1 && q0.v2 == r0.v2 && q0.v3 == r0.v3 && q0.v4 == r0.v4);
    assert(q1.v1 == r1.v1 && q1.v2 == r1.v2 && q1.v3 == r1.v3 && q1.v4 == r1.v4);

    /* Exhaustive test for `store` and `get` from `std::storage` */
    addr.test_storage_exhaustive();

    res
}
