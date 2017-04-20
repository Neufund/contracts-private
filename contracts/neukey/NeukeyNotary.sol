pragma solidity ^0.4.8;

import "../lib/Owned.sol";
import "../faucet/Faucet.sol";

contract NeukeyNotary is Owned {

  struct deviceInfo {
    uint32 device_id;
    address pub_key;
    uint128 owner; //
  }

  address private notary;
  Faucet private faucet;
  mapping (address => bool) deprecated;

  mapping (address => deviceInfo) devicesByPubkey;
  mapping (uint32 => uint32) devicesByDeviceId;
  mapping (uint128 => uint32) devicesByOwner;

  deviceInfo[] devices;

  modifier notaryOnly() {
    if(msg.sender == notary) {
      _;
    }
  }


  function set_faucet(Faucet faucet_) external notaryOnly {
    faucet = faucet_;
  }

  //Does the owner have ultimate control?
  function set_notary(address notary_) external owner_only {
    notary = notary_;
  }

  //Should the Notary have the right to change owner?
  function set_notary_(address notary_) external notaryOnly {
    notary = notary_;
  }

  function registerNano(address nanoPubKey, uint32 deviceId)
      external notaryOnly
  {
    if(devicesByPubkey[nanoPubKey].device_id != 0) {
//      DeviceAlreadyRegistered(nanoPubKey, deviceId);
      throw; //safe?
    }
    devicesByPubkey[nanoPubKey] = deviceInfo(deviceId,nanoPubKey,0);
    DeviceRegistered(nanoPubKey,deviceId);
  }

  function activateNano(address nanoPubKey, uint128 ownerId)
      external notaryOnly
  {
    if(devicesByPubkey[nanoPubKey].owner != 0) {
  //      DeviceAlreadyActivated(nanoPubKey, devicesByPubkey[nanoPubKey].device_id);
        throw; //safe?
    }
    devicesByPubkey[nanoPubKey].owner = ownerId;
    DeviceActivated(nanoPubKey,devicesByPubkey[nanoPubKey].device_id);
  }

    function sendToOwner(address nanoPubKey, uint device_id, uint32 owner_id)
        external
        notaryOnly
    {
        faucet.register(nanoPubKey);
    }

  function deprecate(address nanoPubKey)
    external notaryOnly
  {
    if(deprecated[nanoPubKey] == true) {
  //    DeviceAlreadyDeprecated(nanoPubKey);
      throw; //safe?
    }
    deprecated[nanoPubKey] = true;
//    faucet.unregister(nanoPubKey);
    DeviceDeprecated(nanoPubKey,devicesByPubkey[nanoPubKey].device_id);
    //!!!What if the user loses it for two days and finds it
    delete devicesByPubkey[nanoPubKey];
  }

  function is_registered(address pubKey) constant external returns (bool) {
    return (devicesByPubkey[pubKey].device_id== 0) ? false : true;
  }

  function is_active(address pubKey) constant external returns (bool) {
    return (devicesByPubkey[pubKey].owner== 0) ? false : true;
  }

  function device_id(address pubKey) constant external returns (uint32) {
    return devicesByPubkey[pubKey].device_id;
  }

//If using Throw Already events are useless
  event DeviceRegistered(address nanoPubKey, uint device_id);
  event DeviceSend(address nanoPubKey, uint device_id);
  event DeviceAlreadyRegistered(address nanoPubKey, uint device_id);
  event DeviceAlreadyActivated(address nanoPubKey, uint device_id);
  event DeviceActivated(address nanoPubKey, uint device_id);
  event DeviceDeprecated(address nanoPubKey, uint device_id);
  event DeviceAlreadyDeprecated(address nanoPubKey);
  // TODO: An enabled device is ellegible for the Faucet contract
}
