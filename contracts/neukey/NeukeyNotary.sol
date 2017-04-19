pragma solidity ^0.4.8;

import "../lib/Owned.sol";
import "../faucet/Faucet.sol";

contract NeukeyNotary is Owned {

  struct deviceInfo {
    uint32 device_id;
    address pub_key;
    uint32 owner; //
  }

  address private notary;
  Faucet private faucet;
  mapping (address => bool) deprecated;
  mapping (address => deviceInfo) registry;

  modifier notary_only() {
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

    function register(address nanoPubKey, uint32 device_id)
        external
        notaryOnly
    {
        //  Needs to store it somewhere
    }

    function sendToOwner(address nanoPubKey, uint device_id, uint32 owner_id)
        external
        notaryOnly
    {
        faucet.register(nanoPubKey);
    }

  function deprecate(address nanoPubKey)
    external notary_only
  {
    // TODO Remove key from deviceInfo (can set to zero)


    faucet.unregister(nanoPubKey);
  }

  function is_registered(address) constant external returns (bool)
  {
      // Bool iff pubkey belongs to a nano
  }

  function is_active(address) constant external returns (bool)
  {
      // Bool iff pubkey belongs to a nano and nano is in hands of a user
  }

  function device_id(address) constant external returns (uint32)
  {
      // Returns the device_id of a given nano by pubkey
  }

  event DeviceRegistered(address nanoPubKey, uint device_id);
  event DeviceSend(address nanoPubKey, uint device_id);

  // TODO: An enabled device is ellegible for the Faucet contract
}
