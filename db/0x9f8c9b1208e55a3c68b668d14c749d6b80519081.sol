pragma solidity ^0.4.21;

// Donate all your ethers to 0x7Ec 
// Made by EtherGuy (<span class="__cf_email__" data-cfemail="3d584955584f5a48447d505c5451135e5250">[email&#160;protected]</span>)
// CryptoGaming Discord https://discord.gg/gjrHXFr
// UI @ htpts://0x7.surge.sh

contract InteractiveDonation{
    address constant public Donated = 0x7Ec915B8d3FFee3deaAe5Aa90DeF8Ad826d2e110;
    
    event Quote(address Sent, string Text, uint256 AmtDonate);

    string public DonatedBanner = "";
    

    
    function Donate(string quote) public payable {
        require(msg.sender != Donated); // GTFO dont donate to yourself
        
        emit Quote(msg.sender, quote, msg.value);
    }
    
    function Withdraw() public {
        if (msg.sender != Donated){
            emit Quote(msg.sender, "OMG CHEATER ATTEMPTING TO WITHDRAW", 0);
            return;
        }
        address contr = this;
        msg.sender.transfer(contr.balance);
    }   
    
    function DonatorInteract(string text) public {
        require(msg.sender == Donated);
        emit Quote(msg.sender, text, 0);
    }
    
    function DonatorSetBanner(string img) public {
        require(msg.sender == Donated);
        DonatedBanner = img;
    }
    
    function() public payable{
        require(msg.sender != Donated); // Nice cheat but no donating to yourself 
    }
    
}