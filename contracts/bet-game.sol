pragma solidity ^0.8.6;

contract BetGame {
    //GM
    address public owner;
    bool isFinshed;

    //紀錄玩家用的 struct
    struct Player {
        address payable addr;
        uint amount;
    }

    //存下大的玩家
    Player[] big;
    //存下小的玩家
    Player[] small;

    //下大的總金額
    uint totalBig;
    //下小的總金額
    uint totalSmall;
    uint nowtime;

    constructor() {
        owner = msg.sender;
        totalSmall = 0;
        totalBig = 0;
        isFinshed = false;
        nowtime = block.timestamp;
    }

    function bet(bool flag) public payable returns (bool) {
        require(msg.value > 0);
        Player memory p = Player(payable(msg.sender), msg.value);
        //透過bool true 表示下大
        if (flag) {
            big.push(p);
            totalBig += p.amount;
        } else {
            small.push(p);
            totalSmall += p.amount;
        }
        return true;
    }

    function open() public payable returns (bool) {
        //開獎至少要遊戲開始後60秒
        // require(block.timestamp > nowtime + 60);
        require(!isFinshed);

        //創造出 0-9的變數 0-4為小 5-9為大
        uint points = uint(
            keccak256(abi.encode(msg.sender, block.timestamp, block.number))
        ) % 9;

        uint i = 0;
        Player memory p;

        if (points >= 5) {
            for (i = 0; i < big.length; i++) {
                p = big[i];
                //給贏家 下注本金+照比例分配獎金
                p.addr.transfer(p.amount + (totalSmall * p.amount) / totalBig);
            }
        } else {
            for (i = 0; i < small.length; i++) {
                p = small[i];
                p.addr.transfer(p.amount + (totalBig * p.amount) / totalSmall);
            }
        }

        isFinshed = true;
        return true;
    }
}
