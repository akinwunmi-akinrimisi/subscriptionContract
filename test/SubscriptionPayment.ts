import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SubscriptionPaymentModule = buildModule(
  "SubscriptionPaymentModule",
  (m) => {
    const subscriptionPayment = m.contract("SubscriptionPayment", [], {});

    return { subscriptionPayment };
  }
);

export default SubscriptionPaymentModule;
