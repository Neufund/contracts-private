/* global artifacts contract it assert web3*/

const NeukeyNotary = artifacts.require('../../contracts/neukey/NeukeyNotary.sol');

import expectThrow from './helpers/expectThrow';

contract('NeukeyNotary', (accounts) => {

  //EuroToken conrtact
  let neukeyNotary;

  let owner = accounts[0];
  let someone1 = accounts[1];
  let someone2 = accounts[2];
  let someone3 = accounts[3];

  let deviceId1 = 1;
  let deviceId2 = 2;
  let deviceId3 = 3;

  let ownerId1 = 1;
  let ownerId3 = 3;

  beforeEach(async() => {

    //Setup new token
    neukeyNotary = await NeukeyNotary.new();
    await neukeyNotary.set_notary(owner);


  });

     it('Should register/activate only new Nanos', async () =>  {
       assert(!await neukeyNotary.is_registered.call(someone1));
       assert(await neukeyNotary.registerNano(someone1,deviceId1,{from: owner}));
       assert(await neukeyNotary.is_registered.call(someone1));
       assert(!await neukeyNotary.is_active.call(someone1));
       assert(!await neukeyNotary.is_registered.call(someone2));
       await expectThrow(neukeyNotary.registerNano(someone1,deviceId1,{from: owner}));
       assert(await neukeyNotary.activateNano(someone1,ownerId1,{from: owner}));
       await expectThrow(neukeyNotary.activateNano(someone1,ownerId1,{from: owner}));
       assert(await neukeyNotary.is_active.call(someone1));
       assert(!await neukeyNotary.is_active.call(someone2));

    });

    it('should deprecate a lost nano', async () =>  {
      assert(await neukeyNotary.registerNano(someone3,deviceId3,{from: owner}));
      assert(await neukeyNotary.activateNano(someone3,ownerId3,{from: owner}));
      assert(await neukeyNotary.is_registered.call(someone3));
      assert(await neukeyNotary.is_active.call(someone3));
      assert(await neukeyNotary.deprecate(someone3));
      await expectThrow(neukeyNotary.deprecate(someone3));
      assert(!await neukeyNotary.is_registered.call(someone3));
      assert(!await neukeyNotary.is_active.call(someone3));

    });


});
