const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("SubscriptionPaymentModule", (m) => {
  const subscriptionPayment = m.contract("SubscriptionPayment", [1000], {});

  return { subscriptionPayment };
});

// deployed address: 0x7816Be392A81b63528dfb1d34fcC29B069857e6A
