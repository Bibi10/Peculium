const PeculiumV2 = artifacts.require('./PeculiumV2.sol');
const Peculium = artifacts.require('./Peculium.sol');
import increaseTime from './helpers/increaseTime'

const upgradeAgent = web3.eth.accounts[9];

contract('PeculiumV2', (investors) => {
  let peculium;
  let peculiumV2;

  beforeEach(async () => {
    peculium = await Peculium.new();
    peculiumV2 = await PeculiumV2.new(upgradeAgent);
  });

  it('should handle complete upgrade scenario', async () => {

    // distribute shares
    await peculium.transfer(investors[1], 2000000000);
    await peculium.transfer(investors[2], 2000000000);
    await peculium.transfer(investors[3], 2000000000);
    await peculium.transfer(investors[4], 2000000000);
    await peculium.transfer(investors[5], 2000000000);
    await peculium.transfer(investors[6], 2000000000);
    await peculium.transfer(investors[7], 2000000000);
    await peculium.transfer(investors[8], 2000000000);

    await increaseTime(86400 * 85 + 1);
    
    await peculium.defrostToken({from: investors[1]});
    await peculium.defrostToken({from: investors[2]});
    await peculium.defrostToken({from: investors[3]});
    await peculium.defrostToken({from: investors[4]});
    await peculium.defrostToken({from: investors[5]});
    await peculium.defrostToken({from: investors[6]});
    await peculium.defrostToken({from: investors[7]});
    await peculium.defrostToken({from: investors[8]});

    assert.equal((await peculium.balanceOf.call(investors[1])).toNumber(), 2000000000);
    assert.equal((await peculium.balanceOf.call(investors[2])).toNumber(), 2000000000);
    assert.equal((await peculium.balanceOf.call(investors[3])).toNumber(), 2000000000);
    assert.equal((await peculium.balanceOf.call(investors[4])).toNumber(), 2000000000);
    assert.equal((await peculium.balanceOf.call(investors[5])).toNumber(), 2000000000);
    assert.equal((await peculium.balanceOf.call(investors[6])).toNumber(), 2000000000);
    assert.equal((await peculium.balanceOf.call(investors[7])).toNumber(), 2000000000);
    assert.equal((await peculium.balanceOf.call(investors[8])).toNumber(), 2000000000);

    // start upgrade process for v2
    await peculium.transfer(upgradeAgent, 2000000000, {from: investors[1]});
    await peculium.transfer(upgradeAgent, 2000000000, {from: investors[2]});
    await peculium.transfer(upgradeAgent, 2000000000, {from: investors[3]});
    await peculium.transfer(upgradeAgent, 2000000000, {from: investors[4]});
    await peculium.transfer(upgradeAgent, 2000000000, {from: investors[5]});
    await peculium.transfer(upgradeAgent, 2000000000, {from: investors[6]});
    await peculium.transfer(upgradeAgent, 2000000000, {from: investors[7]});
    await peculium.transfer(upgradeAgent, 2000000000, {from: investors[8]});


    await peculiumV2.assignTokens(investors[1], 2000000000, {from: upgradeAgent});
    await peculiumV2.assignTokens(investors[2], 2000000000, {from: upgradeAgent});
    await peculiumV2.assignTokens(investors[3], 2000000000, {from: upgradeAgent});
    await peculiumV2.assignTokens(investors[4], 2000000000, {from: upgradeAgent});
    await peculiumV2.assignTokens(investors[5], 2000000000, {from: upgradeAgent});
    await peculiumV2.assignTokens(investors[6], 2000000000, {from: upgradeAgent});
    await peculiumV2.assignTokens(investors[7], 2000000000, {from: upgradeAgent});
    await peculiumV2.assignTokens(investors[8], 2000000000, {from: upgradeAgent});
  });
});
