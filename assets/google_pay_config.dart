// Replace the defaultGooglePayConfigString with this configuration
// Update the values with your actual Google Pay Console details

const String defaultGooglePayConfigString = '''
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "stripe",
            "gatewayMerchantId": "YOUR_STRIPE_MERCHANT_ID"
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "YOUR_GOOGLE_PAY_MERCHANT_ID",
      "merchantName": "Your App Name"
    },
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "0.00",
      "currencyCode": "USD"
    }
  }
}
''';

// Alternative configuration for other payment processors:

// For Square:
const String googlePayConfigSquare = '''
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "square",
            "gatewayMerchantId": "YOUR_SQUARE_APPLICATION_ID"
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "YOUR_GOOGLE_PAY_MERCHANT_ID",
      "merchantName": "Your App Name"
    }
  }
}
''';

// For Braintree:
const String googlePayConfigBraintree = '''
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "braintree",
            "braintree:apiVersion": "v1",
            "braintree:sdkVersion": "3.0.0",
            "braintree:merchantId": "YOUR_BRAINTREE_MERCHANT_ID",
            "braintree:clientKey": "YOUR_BRAINTREE_CLIENT_KEY"
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "YOUR_GOOGLE_PAY_MERCHANT_ID",
      "merchantName": "Your App Name"
    }
  }
}
''';

// For direct integration (you handle the payment processing):
const String googlePayConfigDirect = '''
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX", "DISCOVER"]
        },
        "tokenizationSpecification": {
          "type": "DIRECT"
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "YOUR_GOOGLE_PAY_MERCHANT_ID",
      "merchantName": "Your App Name"
    }
  }
}
''';
