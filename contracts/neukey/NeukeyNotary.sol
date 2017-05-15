/*Nano ledger can have diffrent states:
        1-Unregistered: Nano taken out of the box
        2-Register: Nano's DeviceID and Publickey are stored with (registerNano) "Notary"
        3-Activate: An owner with OwnerID is assigned to Nano by notary (activateNano) "Notary"
        4-Confirm: An owner Confirms receiving the Nano (confirmNano) "Client"
        5-Deprecate: In case Nano is lost or stolen Owner reports to Notary and Nano "Notary"
        gets disabled (deprecate)
*/

pragma solidity ^0.4.8;

import "../lib/Owned.sol";
//import "../faucet/Faucet.sol";

contract NeukeyNotary is Owned {

  struct deviceInfo {
    uint32 deviceId;
    address pubKey;
    uint128 owner; //why uint128
    bool userConfirm;
  }

  address private notary;
  //Faucet private faucet;

  mapping (address => uint32) devicesByPubkey;
  mapping (uint32 => bool) deprecated;
  mapping (uint32 => deviceInfo) devicesById;
  mapping (uint128 => bool) devicesByOwner;

  deviceInfo[] devices; //should all stored data be put here?

  modifier notaryOnly() {
    if(msg.sender == notary) {
      _;
    }
  }

//  function set_faucet(Faucet faucet_) external owner_only {
  //  faucet = faucet_;
  //}

  function setNotary(address notary_) external owner_only {
    notary = notary_;
  }

  function registerNano(address nanoPubKey, uint32 deviceId)
      external notaryOnly
  {
    if(devicesById[deviceId].deviceId != 0 ||
        devicesByPubkey[nanoPubKey] !=0 ||
          deprecated[deviceId] == true ||
          deviceId == 0)
      throw;
    devicesById[deviceId] = deviceInfo(deviceId,nanoPubKey,0,false);
    devicesByPubkey[nanoPubKey] = deviceId;
    DeviceRegistered(nanoPubKey,deviceId);
  }

  function activateNano(uint32 deviceId, uint128 ownerId)
      external notaryOnly
  {
    if(devicesById[deviceId].owner != 0 ||
       devicesById[deviceId].pubKey == 0 ||
       devicesById[deviceId].deviceId == 0 ||
        deprecated[deviceId] == true ||
        devicesByOwner[ownerId] == true ||
        ownerId == 0 || deviceId == 0)
        throw;
    devicesById[deviceId].owner = ownerId;
    devicesByOwner[ownerId] = true;
    DeviceActivated(devicesById[deviceId].pubKey,deviceId);
    //faucet.register(devicesById[deviceId].pubKey);
  }

  function confirmNano()
  {
    if(deprecated[devicesByPubkey[msg.sender]] == true)
       throw;
    if(msg.sender != devicesById[devicesByPubkey[msg.sender]].pubKey ||
       devicesById[devicesByPubkey[msg.sender]].owner == 0 ||
       devicesById[devicesByPubkey[msg.sender]].userConfirm == true)
        throw;
    devicesById[devicesByPubkey[msg.sender]].userConfirm = true;
    DeviceConfirmed(devicesByPubkey[msg.sender], devicesById[devicesByPubkey[msg.sender]].deviceId);
  }

  function deprecate(uint32 deviceId)
    external notaryOnly
  {
   if(deprecated[deviceId] == true ||
       devicesById[deviceId].deviceId == 0 ||
       deviceId == 0)
      throw;
    deprecated[deviceId] = true;
    //faucet.unregister(nanoPubKey); LOOK AT ME!!
    DeviceDeprecated(devicesById[deviceId].pubKey,deviceId);
    //!!!What if the user loses it for two days and finds it
    delete devicesByPubkey[devicesById[deviceId].pubKey];
    delete devicesById[deviceId];
  }
  function unDeprecate(uint32 deviceId)
    external owner_only
  {
   if(deprecated[deviceId] == false ||
       deviceId == 0)
      throw;
    delete deprecated[deviceId];
    DeviceUnDeprecated(deviceId);
  }

  function isRegistered(uint32 deviceId) constant external returns (bool) {
    return (devicesById[deviceId].deviceId == 0) ? false : true;
  }

  function isActive(uint32 deviceId) constant external returns (bool) {
    return (devicesById[deviceId].owner == 0) ? false : true;
  }

  function isDeprecated(uint32 deviceId) constant external returns (bool) {
    return (deprecated[deviceId] == true) ? true : false;
  }

  function nanoStates(uint32 deviceId) constant external returns (uint32, address
      ,uint128, bool)
  {
    return (devicesById[deviceId].deviceId,devicesById[deviceId].pubKey,
            devicesById[deviceId].owner,devicesById[deviceId].userConfirm);
  }

  function isConfirmed(address Pubkey) constant external returns (bool) {
    return (devicesById[devicesByPubkey[Pubkey]].userConfirm == false) ? false : true;
  }


  event DeviceRegistered(address nanoPubKey, uint deviceId);
  event DeviceSend(address nanoPubKey, uint deviceId);
  event DeviceActivated(address nanoPubKey, uint deviceId);
  event DeviceConfirmed(address nanoPubKey, uint deviceId);
  event DeviceDeprecated(address nanoPubKey, uint deviceId);
  event DeviceUnDeprecated(uint deviceId);

  // TODO: An enabled device is ellegible for the Faucet contract
  //       Disscuss more the idea of deprecation
  //       Add owner_id mapping and pubkey for registration check
}
