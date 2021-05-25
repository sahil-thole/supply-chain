pragma solidity ^0.7.6;
contract shipment{
    address payable public buyer;
    address payable public seller;
    uint public value;
    enum State{
        Created,
        Locked,
        Released,
        Inactive
    }
    State public state;
    event aborted();
    event confirmedPurchase();
    event orderRecieved();
    event sellerRefunded();
    modifier condition(bool _condition){
        require(_condition);
        _;
    }
    modifier onlyBuyer(){
        require(msg.sender == buyer);
        _;
    }
    modifier onlySeller(){
        require(msg.sender == seller);
        _;
    }
    modifier inState(State _state){
        require(state == _state);
        _;
    }
    constructor()payable{
        seller = payable(msg.sender);
        value = msg.value/2;
        require(2 * value == msg.value , "not even");
    }
    function abort() public onlySeller inState(State.Created){
        emit aborted();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
    function confirmPurchase() public inState(State.Created) condition(msg.value == 2* value) payable{
        emit confirmedPurchase();
        buyer = payable(msg.sender);
        state = State.Locked;
    }
    function confirmRecieved() public onlyBuyer inState(State.Locked){
        emit orderRecieved();
        state = State.Released;
        buyer.transfer(value);
    }
    function refundSeller() public onlySeller inState(State.Released){
        emit sellerRefunded();
        state = State.Inactive;
        seller.transfer(3*value);
    }
}
