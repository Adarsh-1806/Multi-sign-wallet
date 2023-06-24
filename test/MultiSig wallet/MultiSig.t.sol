pragma solidity ^0.8.13;
// import "https://github.com/ConsenSysMesh/openzeppelin-solidity/contracts/utils/Address.sol";
// import "https://github.com/ConsenSysMesh/openzeppelin-solidity/contracts/utils/Context.sol";
// import "https://github.com/ConsenSysMesh/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}
contract MultiSigWalletTest is MultiSigWallet {
    constructor(address[] memory _signers, uint8 _required_approvals)
        MultiSigWallet(_signers, _required_approvals)
    {}

    function testCreateTransaction() public {
        // Create a new transaction
        address to = address(0x123);
        uint256 value = 100;
        bytes memory data = "Test";
        
        createTransaction(to, value, data);
        
        // Verify transaction details
        Transaction memory tnx = getTransaction(0);
        assert(tnx.to == to);
        assert(tnx.value == value);
        assert(keccak256(tnx.data) == keccak256(data));
        assert(tnx.executed == false);
        assert(tnx.n_of_confirmations == 0);
    }
    
    function testApproveTransaction() public {
        // Create a new transaction
        address to = address(0x123);
        uint256 value = 100;
        bytes memory data = "Test";
        createTransaction(to, value, data);
        
        // Approve the transaction
        approveTransaction(0);
        
        // Verify approval status
        bool isApproved = approvals[0][msg.sender];
        assert(isApproved == true);
        
        // Verify transaction confirmation count
        Transaction memory tnx = getTransaction(0);
        assert(tnx.n_of_confirmations == 1);
    }
    
    function testExecuteTransaction() public {
        // Create a new transaction
        address to = address(0x123);
        uint256 value = 100;
        bytes memory data = "Test";
        createTransaction(to, value, data);
        
        // Approve the transaction
        approveTransaction(0);
        
        // Execute the transaction
        executeTransaction(0);
        
        // Verify transaction execution status
        Transaction memory tnx = getTransaction(0);
        assert(tnx.executed == true);
    }
    
    function testAddSigner() public {
        // Add new signers
        address[] memory newSigners = new address[](2);
        newSigners[0] = address(0x456);
        newSigners[1] = address(0x789);
        addSigner(newSigners);
        
        // Verify the addition of new signers
        assert(isSigner[newSigners[0]] == true);
        assert(isSigner[newSigners[1]] == true);
        
        // Verify the updated required approvals count
        assert(required_approvals == signers.length);
    }
}
