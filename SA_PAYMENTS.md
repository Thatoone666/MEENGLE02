# ???? South African Payment Methods Guide

## Overview

Meengle supports **8 local South African payment methods** plus international options, optimized for the South African market.

---

## ?? Payment Methods Comparison

| Payment Method | Type | Currency | Fee | Processing | Settlement | Local | BNPL |
|---|---|---|---|---|---|---|---|
| **Ozow** | Open Banking | ZAR | 1.2% | 5 min | 1 day | ? | ? |
| **SnapScan** | Mobile QR | ZAR | 1.5% | Instant | Same day | ? | ? |
| **PayFlex** | BNPL | ZAR | 0% | Instant | 1-2 days | ? | ? 3/6/12m |
| **Yoco** | Card+Mobile | ZAR | 2.5% | Instant | 1-2 days | ? | ? |
| **Capitec** | Direct Bank | ZAR | 1.5% | 5 min | Same day | ? | ? |
| **PayU** | Card Gateway | ZAR | 2.85% | 5-30 sec | 1 day | ? | ? |
| **Stripe** | International | ZAR/USD/EUR | 2.9%+R1.99 | Instant | 1-2 days | ? | ? |
| **PayPal** | Wallet | USD/ZAR | 3.49%+R0.49 | Instant | 1-2 days | ? | ? |

---

## ???? 1. OZOW (Open Banking)

### Overview
**Ozow** is South Africa's leading open banking platform connecting to ALL major SA banks.

### Features
- ?? Direct payment from any SA bank
- ?? Supports: ABSA, FNB, Nedbank, Standard Bank, Capitec, Investec, Bidvest, Discovery
- ?? Multiple payment methods (Bank, eWallet, Credit/Debit)
- ? Fast processing (5 minutes)
- ?? Recurring payments supported
- ?? Secure & trusted by major SA retailers

### Pricing
- **Fee**: 1.2% of transaction
- **Settlement**: 1 business day

### Best For
- ? South African users (primary recommendation)
- ? All bank accounts
- ? Recurring subscriptions

### Implementation
```javascript
const saPaymentService = require('./saPaymentService');

const payment = await saPaymentService.processOzow(
  99.99, // Amount in ZAR
  'ZAR',
  {
    userId: 'user_123',
    name: 'John Doe',
    email: 'john@example.com',
  }
);

// Response:
// {
//   success: true,
//   provider: 'ozow',
//   transactionId: 'ozow_...',
//   redirectUrl: 'https://ozow.com/pay/...',
//   status: 'pending'
// }
```

---

## ?? 2. SNAPSCAN (QR Code Mobile Payments)

### Overview
**SnapScan** is a South African mobile payment platform focused on instant QR code payments.

### Features
- ?? Scan QR code with any SnapScan user's app
- ? Instant payment completion
- ?? Widely supported by SA merchants
- ?? Deep linking for mobile apps
- ?? Secure peer-to-peer payments

### Pricing
- **Fee**: 1.5% of transaction
- **Settlement**: Same day

### Best For
- ? Mobile-first users
- ? Quick, casual payments
- ? Social/peer-to-peer context

### Implementation
```javascript
const payment = await saPaymentService.processSnapScan(
  50.00,
  'ZAR'
);

// Returns QR code for user to scan with SnapScan app
```

---

## ?? 3. PAYFLEX (Buy Now Pay Later - BNPL)

### Overview
**PayFlex** is South Africa's popular "Buy Now, Pay Later" platform offering interest-free installments.

### Features
- ?? Split payments across 3, 6, or 12 months
- ?? **Zero interest** (no hidden charges)
- ? Instant approval
- ?? Each installment = same amount
- ?? Flexible payment scheduling
- ?? Works for any purchase amount

### Installment Options
```
3 Months:  3 equal payments (No interest)
6 Months:  6 equal payments (No interest)
12 Months: 12 equal payments (No interest)
```

### Pricing
- **Fee**: 0% (No transaction fees)
- **Merchant fees apply** (typically 1-2%)

### Example Calculation
```
Original Price: R300
3-Month Plan:   R100/month
6-Month Plan:   R50/month
12-Month Plan:  R25/month
```

### Best For
- ? Budget-conscious users
- ? Subscription upgrades
- ? Premium tier purchases
- ? Higher-value transactions

### Implementation
```javascript
const payment = await saPaymentService.processPayFlex(
  299.97, // Amount in ZAR
  'ZAR',
  6, // 6-month installment plan
  {
    userId: 'user_123',
    email: 'john@example.com',
    description: 'Meengle Wildfire Annual Plan'
  }
);

// Response includes:
// monthlyPayment: 49.99 // For 6-month plan
```

---

## ?? 4. YOCO (Card & Mobile Payments)

### Overview
**Yoco** is a South African fintech offering card and mobile payment solutions for businesses.

### Features
- ?? Debit/Credit cards
- ?? Mobile payment options
- ? Subscriptions supported
- ?? Popular with SA businesses
- ? Quick processing

### Pricing
- **Fee**: 2.5% of transaction
- **Settlement**: 1-2 business days

### Best For
- ? Card payments
- ? Subscriptions
- ? SA business users

---

## ?? 5. CAPITEC BANK (Direct Banking)

### Overview
**Capitec Bank** is South Africa's 4th largest bank with direct payment integration.

### Features
- ?? Direct from Capitec bank accounts
- ? Fast processing (5 minutes)
- ?? South African focus
- ?? Bank-grade security
- ?? Real-time confirmation

### Pricing
- **Fee**: 1.5% of transaction
- **Settlement**: Same day

### Best For
- ? Capitec Bank customers
- ? Fast settlements
- ? South African users

---

## ?? 6. PAYU (Card Payment Gateway)

### Overview
**PayU** is a major payment gateway in South Africa (part of Naspers).

### Features
- ?? Credit & Debit cards
- ?? Bank transfers
- ? Subscriptions
- ?? International support
- ? 5-30 second processing

### Pricing
- **Fee**: 2.85% of transaction
- **Settlement**: 1 business day

### Best For
- ? All card types
- ? Subscriptions
- ? Traditional payments

---

## ?? 7. STRIPE (International Cards)

### Overview
**Stripe** is the global payment processor supporting international cards.

### Features
- ?? Visa, Mastercard, American Express
- ?? Multiple currencies (ZAR, USD, EUR)
- ? Subscriptions & recurring
- ?? Global support
- ?? Advanced analytics

### Pricing
- **Fee**: 2.9% + R1.99
- **Settlement**: 1-2 business days

### Best For
- ? International users
- ? Non-ZAR currencies
- ? Advanced features needed

---

## ?? 8. PAYPAL (Digital Wallet)

### Overview
**PayPal** is an international digital wallet service available in South Africa.

### Features
- ?? PayPal wallet payments
- ?? Card payments via PayPal
- ?? International support
- ? Subscriptions
- ?? Buyer protection

### Pricing
- **Fee**: 3.49% + R0.49
- **Settlement**: 1-2 business days

### Best For
- ? International users with PayPal
- ? Existing PayPal users
- ? Cross-border payments

---

## ?? Recommended Payment Method Selection

### By User Location
```
South African User ? Ozow (Best local option)
International User ? Stripe (Most reliable global)
```

### By User Preference
```
Budget Conscious ? PayFlex (Split payments)
Quick Payment ? SnapScan (Mobile QR)
Business User ? Yoco (Card + Mobile)
Bank Transfer ? Capitec/Ozow
```

### By Transaction Type
```
Subscription ? Capitec, Yoco, PayU, Stripe
Large Purchase ? PayFlex (BNPL)
Quick Payment ? SnapScan
Premium Tier ? PayFlex (3/6/12 months)
```

---

## ?? API Usage

### Get All Payment Methods
```javascript
const saPaymentService = require('./saPaymentService');

const methods = await saPaymentService.getAllPaymentMethods();
// Returns array of all 8 payment methods with details
```

### Get Specific Payment Method
```javascript
const method = await saPaymentService.getPaymentMethod('ozow');
// Returns: { name, type, fees, features, docs, etc. }
```

### Get Recommended Method for User
```javascript
const method = saPaymentService.getRecommendedPaymentMethod('ZA');
// Returns: 'ozow' (for South African users)

const method = saPaymentService.getRecommendedPaymentMethod('US');
// Returns: 'stripe' (for international users)
```

### Process Payment (Generic)
```javascript
// All payment methods can be processed similarly:
const payment = await saPaymentService.process[Method](
  amount,
  currency,
  metadata
);
```

### Verify Payment Status
```javascript
const status = await saPaymentService.verifyPaymentStatus(
  'ozow',
  'transaction_id'
);
// Returns: { status: 'pending'|'completed'|'failed', paid: boolean }
```

---

## ??? Environment Variables Required

```env
# Stripe
STRIPE_SECRET_KEY=sk_test_...

# SnapScan
SNAPSCAN_API_KEY=...

# Yoco
YOCO_API_KEY=...

# PayU
PAYU_API_KEY=...

# PayFlex
PAYFLEX_API_KEY=...

# Capitec
CAPITEC_API_KEY=...

# Ozow
OZOW_API_KEY=...

# PayPal
PAYPAL_CLIENT_ID=...
```

---

## ?? Fee Comparison

### Lowest to Highest
1. **PayFlex**: 0% (0% transaction fee)
2. **Ozow**: 1.2%
3. **SnapScan**: 1.5%
4. **Capitec**: 1.5%
5. **Yoco**: 2.5%
6. **PayU**: 2.85%
7. **Stripe**: 2.9% + R1.99
8. **PayPal**: 3.49% + R0.49

---

## ?? Integration Steps

### 1. Enable Payment Methods
In frontend, show all 8 methods based on user location:

```javascript
// For South African users
const methods = ['ozow', 'snapscan', 'payflex', 'yoco', 'capitec', 'payu'];

// For International users
const methods = ['stripe', 'paypal'];
```

### 2. Display Payment Option
Show recommended method highlighted:

```
[Ozow] ? Recommended for SA
[SnapScan] 
[PayFlex] - Split into 3/6/12
[Other Options...]
```

### 3. Process Payment
Route to appropriate service based on selection:

```javascript
if (method === 'payflex') {
  // Show installment selector
  const installments = [3, 6, 12];
}

const payment = await saPaymentService.process[Method](...);
```

### 4. Handle Response
Redirect user or handle callback:

```javascript
if (payment.redirectUrl) {
  window.location.href = payment.redirectUrl;
}
```

### 5. Verify Payment
Monitor webhook or verify manually:

```javascript
const verified = await saPaymentService.verifyPaymentStatus(
  method,
  transactionId
);
```

---

## ?? Security Considerations

### PCI Compliance
- ? Stripe & PayU handle card data securely
- ? PayFlex uses tokenization
- ? No sensitive data stored locally

### 3D Secure
- ? Supported by all major gateways
- ? Added authentication layer
- ? Reduces fraud/chargebacks

### Data Protection
- ? All connections HTTPS
- ? Encryption in transit
- ? No card numbers stored

---

## ?? Mobile Optimization

### Best Practices
1. **SnapScan**: Perfect for mobile (QR code)
2. **PayFlex**: Mobile-friendly BNPL
3. **Ozow**: Mobile-friendly open banking
4. **Yoco**: Mobile payment support

### Deep Linking
PayFlex, SnapScan, and Ozow support deep linking for seamless mobile experience.

---

## ?? Upsell Strategy with PayFlex

### Use PayFlex for Premium Upgrades
```
Spark+ Upgrade:
- Monthly: R16.99
- PayFlex 3-month: R5.66/month
- PayFlex 6-month: R2.83/month
- PayFlex 12-month: R1.42/month
```

This makes premium tiers more accessible and increases conversions!

---

## ?? Support & Troubleshooting

### Common Issues

**Payment Declined**
- Insufficient funds
- Card expired
- Wrong CVV
- Transaction limit exceeded

**Bank Not Supported**
- Ozow supports all major SA banks
- Some smaller banks may have limits
- PayU as fallback

**Timeout**
- Check internet connection
- Retry with different method
- Contact support

---

## ?? Recommended Setup

### For Maximum Conversions
```
1. Primary: Ozow (most users)
2. Secondary: PayFlex (BNPL for premium)
3. Tertiary: SnapScan (mobile users)
4. Fallback: Stripe (international)
```

### For Maximum Revenue
```
Highlight: PayFlex (higher LTV via installments)
Premium: Capitec (faster settlement)
Standard: Ozow (largest user base)
```

---

## ?? References

- **Ozow**: https://ozow.com
- **SnapScan**: https://snapscan.io
- **PayFlex**: https://payflex.co.za
- **Yoco**: https://yoco.com
- **Capitec**: https://capitec.co.za
- **PayU**: https://payumoney.com
- **Stripe**: https://stripe.com
- **PayPal**: https://paypal.com

---

**Last Updated**: 2026-01-08  
**Version**: 1.0.0  
**Market**: South Africa (ZA)  
**Supported Payment Methods**: 8 Local + 2 International = 10 Total
