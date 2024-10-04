// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the IERC20 interface from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SubscriptionPayment {

    // Struct to manage each provider's subscription plans
    struct SubscriptionPlan {
        uint planId;                     // Unique ID for the subscription plan
        string planName;                 // Name of the subscription plan (e.g., Basic, Premium)
        uint price;                      // Price of the subscription plan (in wei or token units)
        uint paymentInterval;            // Payment interval in seconds (e.g., 30 days for monthly)
    }

    // Struct to manage service providers
    struct ServiceProvider {
        address providerAddress;         // EOA of the service provider
        string providerName;             // Name of the service provider
        mapping(uint => SubscriptionPlan) plans;  // Mapping of plan IDs to subscription plans
        uint totalPlans;                 // Track the total number of plans for this provider
        uint totalSubscribers;           // Total number of users subscribed to the provider's plans
        mapping(address => bool) subscribers; // Mapping to track which users are subscribed to this provider
        uint balance;                    // Amount of funds that can be withdrawn by the provider
    }

    // Struct to track user subscriptions
    struct UserSubscription {
        uint planId;                     // ID of the subscribed plan
        address providerAddress;         // EOA of the service provider
        uint nextPaymentDue;             // Timestamp when the next payment is due
        bool isActive;                   // Whether the subscription is active or paused
        uint approvalDeadline;           // Deadline by which the user must approve the next payment
        uint gracePeriodEnds;            // Timestamp when the grace period ends
        bool isPaymentApproved;          // Whether the user has approved the payment for the current cycle
    }

    // Struct to track user details
    struct UserDetails {
        address userAddress;             // EOA of the user (their wallet address)
        string username;                 // Optional: Username or display name for the user
        uint totalSubscriptions;         // The total number of subscriptions the user has had
        uint activeSubscriptions;        // The number of active subscriptions
        uint registrationDate;           // Timestamp when the user first registered on the platform
    }

    // Mapping to track service providers by their address
    mapping(address => ServiceProvider) public serviceProviders;

    // Mapping to track subscriptions for each user by their address
    mapping(address => UserSubscription) public userSubscriptions;

    // Mapping to track user details
    mapping(address => UserDetails) public userDetails;

    // List of all service providers
    // address[] public allServiceProviders;
    mapping(address => bool) public allServiceProviders;

    // Global settings
    uint public paymentGracePeriod;        // Grace period for payment approval (e.g., 7 days in seconds)
    address public contractOwner;          // Owner of the contract for administrative control
    bool public contractPaused;            // Boolean flag to pause all activities in case of emergency

    // Events
    event ServiceProviderRegistered(address indexed providerAddress, string providerName);
    // event SubscriptionPlanCreated(address indexed user, address indexed providerAddress, uint planId);
    event SubscriptionPlanCreated(
    address indexed providerAddress,
    uint planId,
    string planName
);

    event PaymentApproved(address indexed user, address indexed providerAddress, uint planId);
    event SubscriptionPaused(address indexed user, address indexed providerAddress, uint planId);
    event FundsWithdrawn(address indexed providerAddress, uint amount);

    // Constructor to initialize global settings and contract owner
    constructor(uint _paymentGracePeriod) {
        contractOwner = msg.sender;
        paymentGracePeriod = _paymentGracePeriod;
        contractPaused = false;
    }

    // Modifier to restrict actions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can perform this action");
        _;
    }

    // Modifier to check if the contract is paused
    modifier whenNotPaused() {
        require(!contractPaused, "Contract is paused");
        _;
    }

    // Modifier to check if the caller is a registered service provider
    modifier onlyProvider() {
        require(serviceProviders[msg.sender].providerAddress != address(0), "Not a registered service provider");
        _;
    }


function registerServiceProvider(address _providerAddress, string memory _providerName) external onlyOwner whenNotPaused {
    // Ensure the service provider is not already registered
    require(serviceProviders[_providerAddress].providerAddress != _providerAddress, "Provider already registered");

    // Create and initialize the new service provider in storage
    ServiceProvider storage newServiceProvider = serviceProviders[_providerAddress];
    newServiceProvider.providerAddress = _providerAddress;
    newServiceProvider.providerName = _providerName;
    newServiceProvider.totalPlans = 0;
    newServiceProvider.totalSubscribers = 0;
    newServiceProvider.balance = 0;

    // Mark the provider as registered in the mapping
    allServiceProviders[_providerAddress] = true;

    // Emit an event to log the registration
    emit ServiceProviderRegistered(_providerAddress, _providerName);
}

    
function createSubscriptionPlan(
    string memory _planName,
    uint _price,
    uint _paymentInterval
) external whenNotPaused {
    // Ensure the caller is a registered service provider using the mapping
    require(allServiceProviders[msg.sender], "yet to register");

    // Ensure the price and payment interval are valid
    require(_price > 0, "Price must be greater than 0");
    require(_paymentInterval > 0, "Payment interval must be greater than 0");

    // Increment the total plans for this provider to use as the new plan ID
    uint newPlanId = serviceProviders[msg.sender].totalPlans + 1;

    // Create the new subscription plan and store it in the provider's mapping
    serviceProviders[msg.sender].plans[newPlanId] = SubscriptionPlan({
        planId: newPlanId,
        planName: _planName,
        price: _price,
        paymentInterval: _paymentInterval
    });

    // Update the total plans count for the provider
    serviceProviders[msg.sender].totalPlans = newPlanId;

    // Emit an event to log the creation of a new subscription plan
    emit SubscriptionPlanCreated(msg.sender, newPlanId, _planName);
}

}
