pragma solidity ^0.7.0;

contract simpleFloyd {
    function invest (address _benificiary) public payable {}
    //function finalize() onlyOwner public {}
    //function refund() public {}
    
    uint public startTime;
    uint public endTime;
    uint public weiTokenObjective;
    uint public weiTokenPrice;
    
    mapping (address => uint) public investmentAmountOf;
    uint public investmentReceived;
    uint public investmentRefunded;
    
    bool public isFinalized;
    bool public isRefundAllowed;
    
    address public owner;
    
    constructor(uint _weiTokenPrice, uint _weiTokenObjective)
    payable public
    {
        require(_weiTokenPrice != 0);
        require(_weiTokenObjective!= 0);
        
        weiTokenPrice = _weiTokenPrice;
        weiTokenObjective = _weiTokenObjective;
    }
  
    event LogInvestment(address  investor, uint value);

    event LogTokenAssingment(address  investor, uint numTokens);

    event refund(address investor, uint value);

// we might need treasury wallets 
    function payFloyd(address owner, uint singleFloydPrice, uint FloydsToBuy) public payable {
    address investor = msg.sender;
    uint investVal = require(msg.value = investment);

    
    uint investment = singleFloydPrice * FloydsToBuy;

    investmentAmountOf[investor] += investment;
    investmentReceived += investment;
    
    assignTokens(investor, investVal);
    emit LogInvestment(investor, investVal);


//function inValidInvestment(unit investVal);
  //  internal view returns (bool) {
//    bool nonZeroInvestment = investVal != 0;
  //      return nonZeroInvestment;
    }
}