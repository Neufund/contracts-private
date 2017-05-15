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
  let someone4 = accounts[4];

  let deviceId1 = 1;
  let deviceId2 = 2;
  let deviceId3 = 3;
  let deviceId4 = 4;


  let ownerId1 = 1;
  let ownerId2 = 2;
  let ownerId3 = 3;
  let ownerId4 = 4;

  beforeEach(async() => {

    //Setup new token
    neukeyNotary = await NeukeyNotary.new();
    await neukeyNotary.setNotary(owner);


  });

     it('Should register then activate only new Nanos', async () =>  {
       //Check for state change in First user1
       assert(!await neukeyNotary.isRegistered.call(deviceId1));
       assert(await neukeyNotary.registerNano(someone1,deviceId1,{from: owner}));
       //Should throw when registering again
       await expectThrow(neukeyNotary.registerNano(someone1,deviceId1,{from: owner}));
       assert(await neukeyNotary.isRegistered.call(deviceId1));
       //Activation processes
       assert(!await neukeyNotary.isActive.call(deviceId1));
       assert(await neukeyNotary.activateNano(deviceId1,ownerId1,{from: owner}));
       assert(await neukeyNotary.isActive.call(deviceId1));
       //Should Throw when activating again
       await expectThrow(neukeyNotary.activateNano(deviceId1,ownerId1,{from: owner}));
       assert(await neukeyNotary.confirmNano({from: someone1}));
       assert(await neukeyNotary.isConfirmed.call(someone1));
       //Should throw when activating again
       await expectThrow(neukeyNotary.confirmNano({from: someone1}));
    });

    it('Should Throw if user doesnt register/activate/confirm', async () =>  {
      assert(!await neukeyNotary.isRegistered.call(deviceId2));
      //If you try activate/confirm before regestering a nano
      await expectThrow(neukeyNotary.activateNano(someone2,ownerId2,{from: owner}));
      await expectThrow(neukeyNotary.confirmNano({from: someone2}));
      assert(await neukeyNotary.registerNano(someone2,deviceId2,{from: owner}));
      //If you try to confirm before activating a nano
      await expectThrow(neukeyNotary.confirmNano({from: someone2}));
   });
    it('should deprecate a lost nano', async () =>  {
      assert(await neukeyNotary.registerNano(someone3,deviceId3,{from: owner}));
      assert(await neukeyNotary.activateNano(deviceId3,ownerId3,{from: owner}));
      assert(await neukeyNotary.isRegistered.call(deviceId3));
      assert(await neukeyNotary.isActive.call(deviceId3));
      assert(await neukeyNotary.deprecate(deviceId3));
      await expectThrow(neukeyNotary.deprecate(deviceId3));
      assert(!await neukeyNotary.isRegistered.call(deviceId3));
      assert(!await neukeyNotary.isActive.call(deviceId3));

    });

    it('should throw if A nano is confirmed/activated/registered not in order', async () =>  {
      assert(!await neukeyNotary.isRegistered.call(deviceId4));
      assert(!await neukeyNotary.isActive.call(deviceId4));
      assert(!await neukeyNotary.isConfirmed.call(someone4));
      await expectThrow(neukeyNotary.activateNano(deviceId4,ownerId4,{from: owner}));
      await expectThrow(neukeyNotary.confirmNano({from: someone4}));
      assert(await neukeyNotary.registerNano(someone4,deviceId4,{from: owner}));
      await expectThrow(neukeyNotary.confirmNano({from: someone4}));
      assert(await neukeyNotary.activateNano(deviceId4,ownerId4,{from: owner}));
      await expectThrow(neukeyNotary.confirmNano({from: owner}));
      assert(await neukeyNotary.confirmNano({from: someone4}));
      assert(await neukeyNotary.isRegistered.call(deviceId4));
      assert(await neukeyNotary.isActive.call(deviceId4));
      assert(await neukeyNotary.isConfirmed.call(someone4));
      //Testing the whole structure should
      //let test = await neukeyNotary.nanoStates.call(deviceId4);
      //console.log(test);
    });



});
