pragma solidity >=0.8.2 <0.9.0;
interface MoblieOS {}
interface PowerFullChipset {}

contract Phone is MoblieOS {}
contract IPhone is Phone, PowerFullChipset {}
contract Test1 {
    uint16 public price;
    function TestPhone() public {
        Phone ph = new Phone();
        Phone ph2 = new IPhone();
        IPhone iph = new IPhone();
    }
}
