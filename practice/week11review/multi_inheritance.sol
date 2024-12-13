abstract contract ParentA {
    function retnStr() public virtual returns (string memory) {
        return "From ParentA";
    }
}

abstract contract ParentB {
    function retnStr()public  virtual returns (string memory){
        return "From ParentB";
    }
}

contract Child is ParentA, ParentB {
    function retnStr() public override returns (string memory){
        return super.retnStr();
    }
}
