// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

/*
 Top 3 tasks remaining 

 0.5 => In line 177 ...reset array to empty array...giving error for some reason
 1. complete getRandomNumber 
 2. complete getNFTPrice and checkEntryAvailable
 3. Make a function to call start and pick winner at correct times!
 

 New problem =>
 1. The contract needs a fee components like in other NFT Market Place to cover the gas cost invovlved as we are not chargin ETH as entry fee
 
*/

/*
Optional tasks 
1. add a treasury to check the nft that is owned by the contract 
*/

contract Lottery is ReentrancyGuard{

    address public owner ;
    
    // LOTTERY OBJECTS
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

/*
    change this struct to reduce the unnecessary parameters => add a fee portion
*/
    struct Item {
        IERC721 nft;
        uint tokenId;
        uint price;
        address payable player;
    }
    
    
    //LOTTERY CURRENT USE VARIABLES
    Item[] public items;

    

    //LOTTERY STATE VARIABLES 
    uint internal balance ;
    LOTTERY_STATE public lottery_state;


    //LOTTERY HISTORY VARIABLES
    address[] public winners;
    address public recentWinner;

    //CHAINLINK VARIABLES



    // EVENT 
    event WinnerPicked(
        address indexed winner
    );
    event EnteredLottery(
        address indexed nft,
        uint tokenId,
        address indexed participant
    );

    // MODIFIERS
    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }


    constructor(){
        owner = msg.sender ;
        lottery_state = LOTTERY_STATE.CLOSED;
    }
    

    /*
    
    complete getPriceFunction

    */
    function getNFTPrice(IERC721 _nft,uint _tokenId) public returns(uint){
        // check first if floor price exist 
        // then calculate the price 
        return 1;

    }
    function checkEntryEligible(uint _price) public returns(bool){
        
        return true;
    }



    function enter(IERC721 _nft,uint _tokenId ) public nonReentrant {
        require(
            lottery_state == LOTTERY_STATE.OPEN,
            "Can't join now, Lottery Closed!"
        );

        uint _price = getNFTPrice( _nft, _tokenId );
        require(checkEntryEligible(_price),"Floor Price too Low!!");

        //transfer the NFT 
        _nft.transferFrom(msg.sender, address(this), _tokenId);

        // Make the Item => ENROLL IN LOTTERY
        items.push( Item(
            _nft,
            _tokenId,
            _price,
             payable(msg.sender)
            ));
        


        // update the balance 
        balance+=_price;

        //emit an event 
        emit EnteredLottery(address(_nft),_tokenId, msg.sender);
    }


    function getRandomNumber() public view returns (uint){
        return uint(keccak256(abi.encodePacked(owner,block.timestamp)));
    }

    function pickWinner() public onlyOwner{
        require(
            lottery_state== LOTTERY_STATE.OPEN,
            "The lottery is NOT OPEN !"
            );

        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;

        uint index = getRandomNumber() % items.length;
        address winner = items[index].player;
        
        uint indexContractNFT = getRandomNumber() % items.length;
        
        /*
        Write the function to TRANSFER the NFT and take one for yourself => How to check the gas fee to perfrom this function and if it has enough gas 
        */
        for(uint i=0;i<items.length;i++){
            //write additional stuff to correct when using NFT
            if(i!=indexContractNFT){
            items[i].nft.transferFrom(address(this),winner,items[i].tokenId);
            }
        }

        //take one NFT for yourself and push it into opensea function 

        //emit an event also
        emit WinnerPicked(winner);

        winners.push(winner);
        recentWinner = winner;


        // initialise the array to an empty array
        // items = new Item[](0); 
        balance =0;
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    
    // START-END FUNCTIONS ( Check if needed always - probably can remove)
    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can't start Lottery yet!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }




    //GETTER FUNCTIONS 

    function getBalance() public view returns (uint){
        return balance;
    }
    

    function getWinner() public view    returns (address[] memory) {
        return winners;
    }

    function getRecentWinner() public view returns (address){
        return recentWinner;
    }


}
