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

  mapping (uint32 => bool) deprecated;
  mapping (uint32 => deviceInfo) devicesById;

  deviceInfo[] devices; //should all stored data be put here?

  modifier notaryOnly() {
    if(msg.sender == notary) {
      _;
    }
  }

  //Notary or owner??
  function set_faucet(Faucet faucet_) external notaryOnly {
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

  function confirmNano(uint32 deviceId)
  {
    if(msg.sender != devicesById[deviceId].pubKey ||
       devicesById[deviceId].owner == 0 ||
       devicesById[deviceId].userConfirm == true)
        throw;
    devicesById[deviceId].userConfirm = true;
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
    delete devicesById[deviceId];
  }

  function is_registered(uint32 deviceId) constant external returns (bool) {
    return (devicesById[deviceId].deviceId == 0) ? false : true;
  }

  function is_active(uint32 deviceId) constant external returns (bool) {
    return (devicesById[deviceId].owner == 0) ? false : true;
  }

  function is_confirmed(uint32 deviceId) constant external returns (bool) {
    return (devicesById[deviceId].userConfirm == false) ? false : true;
  }

  function pubKey(uint32 deviceId) constant external returns (address) {
    return devicesById[deviceId].pubKey;
  }

  event DeviceRegistered(address nanoPubKey, uint deviceId);
  event DeviceSend(address nanoPubKey, uint deviceId);
  event DeviceActivated(address nanoPubKey, uint deviceId);
  event DeviceDeprecated(address nanoPubKey, uint deviceId);

  // TODO: An enabled device is ellegible for the Faucet contract
  //     : Anything facuet related
  //
}
