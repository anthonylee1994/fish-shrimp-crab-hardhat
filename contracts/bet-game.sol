// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BetGame is Ownable {
    enum BetType {
        FISH, // 魚
        SHRIMP, // 蝦
        GOURD, // 葫蘆
        COIN, // 金錢
        CRAB, // 蟹
        ROOSTER // 雞
    }

    //紀錄閒家用的 struct
    struct Player {
        address payable addr;
        uint amount;
    }

    struct DrawResult {
        uint openTime;
        uint firstDigit;
        uint secondDigit;
        uint thirdDigit;
    }

    uint poolLiquidityAmount; // 莊家彩池金額

    mapping(uint => DrawResult) public drawResults;

    constructor() {
        transferOwnership(0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199); // 莊家 Wallet 取得擁有權
        poolLiquidityAmount = 0;
    }

    function addLiquidity() public payable returns (bool) {
        poolLiquidityAmount += msg.value;
        return true;
    }

    function takeLiquidity() public payable returns (bool) {
        require(msg.sender == owner(), "Only owner can take liquidity");
        require(poolLiquidityAmount >= msg.value, "Not enough liquidity");
        address payable addr = payable(owner());
        addr.transfer(msg.value);
        poolLiquidityAmount -= msg.value;
        return true;
    }

    function getLiquidity() public view returns (uint) {
        return poolLiquidityAmount;
    }

    function canBet(uint amount) public view returns (bool) {
        return amount < poolLiquidityAmount / 4;
    }

    function bet(uint[] memory amounts) public payable returns (bool) {
        uint totalAmount = 0;

        for (uint i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(msg.value > 0, "Bet amount must be greater than 0");
        require(canBet(msg.value), "Pool liquidity not enough");
        require(
            totalAmount == msg.value,
            "Bet amounts must sum to the bet amount"
        );

        Player memory player = Player(payable(msg.sender), msg.value);
        poolLiquidityAmount += player.amount;

        DrawResult memory drawResult = open();
        drawResults[block.number] = drawResult;

        uint winAmount = 0;

        for (uint i = 0; i < 6; i++) {
            uint multiplier = 1;
            if (drawResult.firstDigit == i) multiplier += 1; // 中第一粒
            if (drawResult.secondDigit == i) multiplier += 1; // 中第二粒
            if (drawResult.thirdDigit == i) multiplier += 1; // 中第三粒

            if (amounts[i] > 0 && multiplier > 1) {
                winAmount += amounts[i] * multiplier;
            }
        }

        // 派彩
        if (winAmount > 0) {
            player.addr.transfer(winAmount);
            poolLiquidityAmount -= winAmount;
        }

        return true;
    }

    function getLastDrawResult() public view returns (DrawResult memory) {
        return drawResults[block.number];
    }

    function randomOf(uint length) private view returns (uint) {
        return
            uint(
                keccak256(abi.encode(msg.sender, block.timestamp, block.number))
            ) % length;
    }

    function open() private view returns (DrawResult memory) {
        uint random = randomOf(6 * 6 * 6);
        uint firstDigit = random % 6;
        uint secondDigit = (random / 6) % 6;
        uint thirdDigit = (random / 36) % 6;

        DrawResult memory drawResult = DrawResult(
            block.timestamp,
            firstDigit,
            secondDigit,
            thirdDigit
        );

        return drawResult;
    }
}
