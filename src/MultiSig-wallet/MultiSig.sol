// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MultiSigWallet {
   event Deposite(address indexed sender, uint256 amount);
   event TransactionCreated(uint256 indexed ransactionId, address indexed receiver,uint256 amount,bytes data);
   event TransactionApproved(address indexed signer,uint256 transactionId);
   event TransactionExecuted(address indexed sender, uint256 amount);

   address[] public signers ;
   address public owner;
   uint256 transactionId;
   uint8 public required_approvals;
   mapping(address => bool ) isSigner;
   mapping(uint256 => mapping(address => bool)) approvals;

   struct Transaction {
    address to;
    uint256 value;
    bytes data;
    bool executed;
    uint8 n_of_confirmations;
   }
   
   mapping(uint256 => Transaction) transactions;
    
    modifier onlyOwner(address _owner){
        require(owner == _owner,"Not Owner");
        _;
    }
    modifier onlyExist(uint256 _id){
        require(transactionId >= _id,"Invalid Transaction Id");
        _;
    }
    modifier onlySigner(address _sender){
        require(isSigner[_sender] == true,"Not Authorized to Sign");
        _;
    }
    modifier notExecuted(uint256 _id){
        require(transactions[_id].executed == false,"Transaction is already Executed");
        _;
    }

    constructor(address[] memory _signers,uint8 _required_approvals){
        require(_signers.length == _required_approvals,"Need to approve Trasaction by all owner");
        owner = msg.sender;
        for(uint8 i=0 ;i<_signers.length;i++){
            address signer = _signers[i];
            
            require(signer != address(0));
            require(isSigner[signer] == false,"Alredy Existed");
            isSigner[signer]=true;
        }
        signers = _signers;
        required_approvals = _required_approvals;
    }

    function createTransaction(address _to, uint256 _value, bytes memory _data) public{
        require(_value > 0,"Amount should be more than Zero");
        transactions[transactionId] = Transaction(
            _to,
            _value,
            _data,
            false,
            0
        );
        emit TransactionCreated(transactionId, _to, _value, _data);
    }
    function approveTransaction(uint256 _id) public onlyExist(_id) onlySigner(msg.sender) notExecuted(_id) {
        
        Transaction storage tnx = transactions[_id];
        approvals[_id][msg.sender] = true;
        tnx.n_of_confirmations += 1;

        emit TransactionApproved(msg.sender,_id);
    }

    function executeTransaction(uint _id) public onlyExist(_id) notExecuted(_id){
        Transaction storage tnx = transactions[_id];
        require(tnx.n_of_confirmations >= required_approvals);
        (bool success ,) = tnx.to.call{value: tnx.value}(tnx.data);

        require(success,"Transaction Failed");
        emit TransactionExecuted(msg.sender, tnx.value);
    }

    function getTransaction(uint256 _id) public view returns(Transaction memory){
        return transactions[_id];
   
    }
    function addSigner(address[] memory _newSigner) public onlyOwner(msg.sender){
        uint8 length= uint8(_newSigner.length);
        required_approvals += length; 
        for (uint8 i = 0; i < length; i++) {
            isSigner[_newSigner[i]] = true;   
            signers.push(_newSigner[i]);   
        }
    }
   
   receive() payable external {
    emit Deposite(msg.sender, msg.value);
   }
}
