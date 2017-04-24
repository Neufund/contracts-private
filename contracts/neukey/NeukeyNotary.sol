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
import "../faucet/Faucet.sol";

contract NeukeyNotary is Owned {

  struct deviceInfo {
    uint32 deviceId;
    address pubKey;
    uint128 owner; //
    bool userConfirm;
  }

  address private notary;
  Faucet private faucet;

  mapping (address => uint32) devicesByPubkey;
  mapping (address => bool) deprecated;
  mapping (uint32 => deviceInfo) devicesById;

  deviceInfo[] devices; //should all stored data be put here?

  modifier notaryOnly() {
    if(msg.sender == notary) {
      _;
    }
  }

  function set_faucet(Faucet faucet_) external owner_only {
    faucet = faucet_;
  }

  function set_notary(address notary_) external owner_only {
    notary = notary_;
  }

  function registerNano(address nanoPubKey, uint32 deviceId)
      external notaryOnly
  {
    if(devicesById[deviceId].deviceId != 0)
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
       devicesById[deviceId].deviceId == 0)
        throw;
    devicesById[deviceId].owner = ownerId;
    DeviceActivated(devicesById[deviceId].pubKey,deviceId);
    //faucet.register(devicesById[deviceId].pubKey);
  }

  function confirmNano()
  {
    if(msg.sender != devicesById[devicesByPubkey[msg.sender]].pubKey ||
       devicesById[devicesByPubkey[msg.sender]].owner == 0 ||
       devicesById[devicesByPubkey[msg.sender]].userConfirm == true)
        throw;
    devicesById[devicesByPubkey[msg.sender]].userConfirm = true;
  }

  function deprecate(uint32 deviceId)
    external notaryOnly
  {
    if(deprecated[deviceId] == true)
      throw;
    deprecated[deviceId] = true;
    //faucet.unregister(nanoPubKey); LOOK AT ME!!
    DeviceDeprecated(devicesById[deviceId].pubKey,deviceId);
    //!!!What if the user loses it for two days and finds it
    delete devicesByPubkey[devicesById[deviceId].pubKey];
    delete devicesById[deviceId];
  }

  function is_registered(uint32 deviceId) constant external returns (bool) {
    return (devicesById[deviceId].deviceId == 0) ? false : true;
  }

  function is_active(uint32 deviceId) constant external returns (bool) {
    return (devicesById[deviceId].owner == 0) ? false : true;
  }

  function nanoStates(uint32 deviceId) constant external returns (uint32, address
      ,uint128, bool)
  {
    return (devicesById[deviceId].deviceId,devicesById[deviceId].pubKey,
            devicesById[deviceId].owner,devicesById[deviceId].userConfirm);
  }

  function is_confirmed(address Pubkey) constant external returns (bool) {
    return (devicesById[devicesByPubkey[Pubkey]].userConfirm == false) ? false : true;
  }


  event DeviceRegistered(address nanoPubKey, uint deviceId);
  event DeviceSend(address nanoPubKey, uint deviceId);
  event DeviceActivated(address nanoPubKey, uint deviceId);
  event DeviceDeprecated(address nanoPubKey, uint deviceId);

  // TODO: An enabled device is ellegible for the Faucet contract
}
