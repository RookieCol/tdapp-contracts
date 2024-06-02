// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract TelegramAdPlatform {
    address public owner;

    enum Plan { NONE, DAY, WEEK }

    uint256 public constant DAY = 1 days;
    uint256 public constant WEEK = 7 days;

    mapping(Plan => uint256) public planPercentages; // Percentage fee for each plan in basis points (bps)

    struct ChannelOwner {
        address wallet;
        bool isRegistered;
    }

    struct Ad {
        address advertiser;
        uint256 channelId;
        uint256 startTime;
        uint256 duration;
        uint256 amount;
        Plan plan;
    }

    mapping(uint256 => ChannelOwner) public channelOwners;
    mapping(uint256 => Ad) public ads;

    event ChannelRegistered(uint256 indexed channelId, address indexed owner);
    event AdCreated(uint256 indexed adId, address indexed advertiser, uint256 indexed channelId, uint256 startTime, uint256 duration, uint256 amount, Plan plan);
    event AdPaymentReleased(uint256 indexed adId, uint256 amount);

    constructor(address _owner) {
        owner = _owner;
        planPercentages[Plan.NONE] = 0; // 0%
        planPercentages[Plan.DAY] = 800; // 8%
        planPercentages[Plan.WEEK] = 1000; // 10%
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function registerChannelOwner(uint256 channelId, address wallet) external onlyOwner {
        require(!channelOwners[channelId].isRegistered, "Channel owner already registered");
        channelOwners[channelId] = ChannelOwner({
            wallet: wallet,
            isRegistered: true
        });
        emit ChannelRegistered(channelId, wallet);
    }

    function createAd(uint256 adId, uint256 channelId, Plan plan) external payable {
        require(channelOwners[channelId].isRegistered, "Channel owner not registered");
        require(plan != Plan.NONE, "Invalid plan");

        uint256 planFeePercentage = planPercentages[plan];
        uint256 fee = (msg.value * planFeePercentage) / 10000; // Calculate the fee based on percentage
        uint256 netAmount = msg.value - fee;

        uint256 duration;
        if (plan == Plan.DAY) {
            duration = DAY;
        } else if (plan == Plan.WEEK) {
            duration = WEEK;
        } else {
            duration = 0;
        }

        ads[adId] = Ad({
            advertiser: msg.sender,
            channelId: channelId,
            startTime: block.timestamp,
            duration: duration,
            amount: netAmount,
            plan: plan
        });

        payable(owner).transfer(fee); // Transfer the fee to the owner

        emit AdCreated(adId, msg.sender, channelId, block.timestamp, duration, msg.value, plan);
    }

    function releaseAdPayment(uint256 adId) external onlyOwner {
        Ad storage ad = ads[adId];
        require(ad.amount > 0, "Ad payment already released or not valid");

        payable(channelOwners[ad.channelId].wallet).transfer(ad.amount);
        emit AdPaymentReleased(adId, ad.amount);

        ad.amount = 0; // Mark as paid
    }

    function getAdDetails(uint256 adId) external view returns (address advertiser, uint256 channelId, uint256 startTime, uint256 duration, uint256 amount, Plan plan) {
        Ad storage ad = ads[adId];
        return (ad.advertiser, ad.channelId, ad.startTime, ad.duration, ad.amount, ad.plan);
    }
}
