//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./dependencies/token.sol";

contract Disney{
    //---------------------- INITIAL DECLARATIONS ----------------------
    //instance of the token contract
   ERC20Basic private token;
    //address of the owner
   address payable public owner;
    uint tokenPrice;
    //constructor
   constructor(){
       token = new ERC20Basic(10000);
       owner = payable(msg.sender);
       tokenPrice = 1 ether;
   }

   //data struct to store disney clients
struct client{
    uint purchased_tokens;
    string [] games_played;
}
//mapping for the clients registry
mapping (address => client) public clients;

//setting events
event purchasedTokens(uint amount, address adr);
event tokenPriceChanged(uint newPrice, uint oldPrice);

//---------------------- TOKENS MANAGEMENT ----------------------

// function to set the token price
function getTokenPrice(uint _numTokens) internal view returns (uint){
    //ATM 1 token = 1 ether.
    return _numTokens * tokenPrice;
}

//set the new token price
function setTokenPrice(uint _newPrice) public onlyOwner(msg.sender){
    require(_newPrice >= 1);
    emit tokenPriceChanged(_newPrice, tokenPrice);
    tokenPrice = _newPrice * 1 ether;
}

// function to buy disney tokens
function BuyTokens(uint _numTokens) public payable {
    // set tokens price
    uint cost = getTokenPrice(_numTokens);
    //check the money that the client pays for tokens
    require(cost <= msg.value, "buy less tokens or send more eth");
    //substract the amount of eth sent by the client by the cost of buying that amount of tokens
    uint returnValue = msg.value - cost;
    //disney returns the amount of eth to the client
    address payable sender = payable(msg.sender);
    sender.transfer(returnValue);
    // get the number of tokens available
    uint balance = balanceOf();
    require(_numTokens <= balance, "buy a lower amount of tokens");
    // transfer the amount of tokens to the client
    token.transfer(msg.sender, _numTokens);
    //register tokens bought
    clients[msg.sender].purchased_tokens += _numTokens;
    emit purchasedTokens(_numTokens, msg.sender);
}
//tokens balance of Disney contract
function balanceOf() public view returns(uint){
    //using address(this) and the function balanceOf we can see the current balance of the SC.
    return token.balanceOf(address(this));
}

//view the remianing amount of tokens of a client
function MyTokens()public view returns(uint){
    return token.balanceOf(msg.sender);
}

// mint new tokens
function MintTokens(uint _numTokens) public onlyOwner(msg.sender){
    token.increaseTotalSupply(_numTokens);
}

// modifier to allow only the owner to execute a function
modifier onlyOwner(address _adr){
    require(_adr == owner, "you're not allowed to execute this function");
    _;
}

//---------------------- DISNEY MANAGEMENT ----------------------

//events
event enjoy_game(string);
event new_game(string name, uint price);
event cancel_game(string);

//game struct
struct game {
    string name;
    uint price;
    bool state;
}

//mapping to store games by their name
mapping (string => game) public gameMapping;

//array to store the name of different games
string [] games;

//store all the games that a client played 
mapping (address => string []) gamesHistory;

//create a new game (only the owner is able to execute it)
function NewGame(string memory _gameName, uint _price) public onlyOwner(msg.sender){
    //create a new game in Disney
    gameMapping[_gameName] = game(_gameName, _price, true);
    //store into an array the name of the game
    games.push(_gameName);
    emit new_game(_gameName, _price);
}
//function to cancel a game
function CancelGame (string memory _gameName) public onlyOwner(msg.sender){
    //set the state as false
    gameMapping[_gameName].state = false;
    //emit the cancel_game event
    emit cancel_game(_gameName);
}

//view disney games
function AvailableGames() public view returns (string [] memory){
    return games; 
}

//function to play a disney game and pay with tokens

function playGame(string memory _gameName) public{
    //price of the game
    uint price = gameMapping[_gameName].price;
    //verify the state of the game
    require(gameMapping[_gameName].state, "this game is not available currently");
    require(MyTokens() >= price, "you need more tokens to play this game");

    /*
    The client pays the game with Tokens:
    -We had to create a new function in token.sol file named: 'transfer_disney' 
    because in case of using Transfer or TransferFrom the choose addresses were wrong.
    Transfer and TransferFrom uses the amount of tokens of the SC, here we want to use
    the amount of tokens of the user.
     */
     token.transfer_disney(msg.sender, address(this), price);
     //storing this into the history map
    gamesHistory[msg.sender].push(_gameName);
    //emit the event
    emit enjoy_game(_gameName);
} 

//view the whole client history
function viewHistory() public view returns (string [] memory){
    return gamesHistory[msg.sender];
}

//returns remaining tokens
function returnTokens(uint _numTokens) public payable {
    require(_numTokens <= MyTokens(), "you don't have that amount of tokens");
    token.transfer_disney(msg.sender, address(this), _numTokens);
    address payable sender = payable(msg.sender);
    sender.transfer(getTokenPrice(_numTokens));
}

}