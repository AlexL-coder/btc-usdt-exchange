const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BTCUSDTExchange", function () {
let BTCUSDTExchange, exchange, owner, addr1;
let mockBTCPriceFeed, mockUSDTPriceFeed;

beforeEach(async function () {
// Mock Chainlink Price Feeds
const MockPriceFeed = await ethers.getContractFactory("MockV3Aggregator");
mockBTCPriceFeed = await MockPriceFeed.deploy(8, ethers.utils.parseUnits("30000", 8)); // $30,000
mockUSDTPriceFeed = await MockPriceFeed.deploy(8, ethers.utils.parseUnits("1", 8)); // $1

// Deploy the BTCUSDTExchange contract
BTCUSDTExchange = await ethers.getContractFactory("BTCUSDTExchange");
[owner, addr1] = await ethers.getSigners();
exchange = await BTCUSDTExchange.deploy(mockBTCPriceFeed.address, mockUSDTPriceFeed.address);
});

it("Should fetch correct BTC to USD price", async function () {
const btcPrice = await exchange.getBTCToUSDPrice();
expect(btcPrice).to.equal(ethers.utils.parseUnits("30000", 0));
});

it("Should fetch correct USDT to USD price", async function () {
const usdtPrice = await exchange.getUSDTToUSDPrice();
expect(usdtPrice).to.equal(ethers.utils.parseUnits("1", 0));
});

it("Should correctly convert BTC to USDT", async function () {
const btcAmount = ethers.utils.parseUnits("1", 8); // 1 BTC
const usdtAmount = await exchange.convertBTCToUSDT(btcAmount);
expect(usdtAmount).to.equal(ethers.utils.parseUnits("30000", 8)); // 30,000 USDT
});

it("Should correctly convert USDT to BTC", async function () {
const usdtAmount = ethers.utils.parseUnits("30000", 8); // 30,000 USDT
const btcAmount = await exchange.convertUSDTToBTC(usdtAmount);
expect(btcAmount).to.equal(ethers.utils.parseUnits("1", 8)); // 1 BTC
});

it("Should emit an event on BTC to USDT exchange", async function () {
const btcAmount = ethers.utils.parseUnits("1", 8);
await expect(exchange.connect(addr1).exchangeBTCToUSDT(btcAmount, { value: btcAmount }))
.to.emit(exchange, "Exchange")
.withArgs(addr1.address, "BTC", "USDT", btcAmount, ethers.utils.parseUnits("30000", 8));
});

it("Should emit an event on USDT to BTC exchange", async function () {
const usdtAmount = ethers.utils.parseUnits("30000", 8);
await expect(exchange.connect(addr1).exchangeUSDTToBTC(usdtAmount))
.to.emit(exchange, "Exchange")
.withArgs(addr1.address, "USDT", "BTC", usdtAmount, ethers.utils.parseUnits("1", 8));
});
});
