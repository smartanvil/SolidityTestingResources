// Timelock
// lock withdrawal for a set time period
// @authors:
// Cody Burns <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="73171c1d0703121d1a1033101c170a041106011d005d101c1e">[email&#160;protected]</a>>
// license: Apache 2.0
// version:

pragma solidity ^0.4.19;

// Intended use: lock withdrawal for a set time period
//
// Status: functional
// still needs:
// submit pr and issues to https://github.com/realcodywburns/
//version 0.2.0


contract timelock {

////////////////
//Global VARS//////////////////////////////////////////////////////////////////////////
//////////////

    uint public freezeBlocks = 2000;       //number of blocks to keep a lockers (2k)

///////////
//MAPPING/////////////////////////////////////////////////////////////////////////////
///////////

    struct locker{
      uint freedom;
      uint bal;
    }
    mapping (address => locker) public lockers;

///////////
//EVENTS////////////////////////////////////////////////////////////////////////////
//////////

    event Locked(address indexed locker, uint indexed amount);
    event Released(address indexed locker, uint indexed amount);

/////////////
//MODIFIERS////////////////////////////////////////////////////////////////////
////////////

//////////////
//Operations////////////////////////////////////////////////////////////////////////
//////////////

/* public functions */
    function() payable public {
        locker storage l = lockers[msg.sender];
        l.freedom =  block.number + freezeBlocks; //this will reset the freedom clock
        l.bal = l.bal + msg.value;

        Locked(msg.sender, msg.value);
    }

    function withdraw() public {
        locker storage l = lockers[msg.sender];
        require (block.number > l.freedom && l.bal > 0);

        // avoid recursive call

        uint value = l.bal;
        l.bal = 0;
        msg.sender.transfer(value);
        Released(msg.sender, value);
    }

////////////
//OUTPUTS///////////////////////////////////////////////////////////////////////
//////////

////////////
//SAFETY ////////////////////////////////////////////////////////////////////
//////////


}