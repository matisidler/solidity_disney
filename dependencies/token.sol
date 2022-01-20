//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../lib/SafeMath.sol";

//adr 1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 (owner of the sc)
//adr 2: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//adr 3: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

//interface of the token
interface IERC20{



    //returns the amount of available tokens
    function totalSupply() external view returns(uint256);

    //returns the balance of an address received as a parameter
    function balanceOf(address account) external view returns (uint256);

    //returns the number of tokens that the sender would be able to spend in name of the owner
    function allowance(address owner, address spender) external view returns (uint256);

    //returns the result of the indicated operation
    function transfer(address recipient, uint256 amount) external returns (bool); 

    //returns the boolean value with the result of the spending operation
    function approve(address spender, uint256 amount) external returns(bool);

    //returns a boolean value with the result of the operation of transferring tokens using the allowance method
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    //event that should be emmitted when an amount of tokens is transferred from an origin to another address
    event Transfer(address from, address to, uint256 value);

    //event that sould be emitted when the allowance method is executed
    event Approval(address owner, address sprender, uint256 value);

    function transfer_disney(address client, address recipient, uint256 amount) external returns (bool);

}

contract ERC20Basic is IERC20{
    //name of the token
    string public constant name = "DisneyToken";
    //symbol of the token
    string public constant symbol = "DIS";
    //allowed decimals of the token. i.e: 0.000000001
    uint8 public constant decimals = 2; 
    

    using SafeMath for uint256;
    //this map stores the balances of every address
    mapping (address => uint) private balances;
    //this map stores the addresses allowed to use the money of other addresses
    mapping (address => mapping(address => uint)) private allowed; 
    //the total supply of the token
    uint256 private totalSupply_;

    constructor(uint256 initialSupply){
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns(uint256){
        return totalSupply_;
    }

    function balanceOf(address account) public override view returns (uint256){
        return balances[account];
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
         
    }

    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool){
        require(amount <= balances[msg.sender], "the amount sent is higher than the current balance of the account");
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address delegate, uint256 amount) public override returns(bool){
        require(balances[msg.sender] >= amount, "the amount must be lower or equal than the current balance of the account");
        allowed[msg.sender][delegate] += amount;
        emit Approval(msg.sender, delegate, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool){
        require(amount <= balances[sender]);
        require(allowed[sender][msg.sender] >= amount);

        balances[sender] = balances[sender].sub(amount);
        allowed[sender][msg.sender] = allowed[sender][msg.sender].sub(amount); 
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

        function transfer_disney(address client, address recipient, uint256 amount) public override returns (bool){
        require(amount <= balances[client], "the amount sent is higher than the current balance of the account");
        balances[client] = balances[client].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(client, recipient, amount);
        return true;
    }
}