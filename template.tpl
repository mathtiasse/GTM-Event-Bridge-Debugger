___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Event Bridge Debugger",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Track every signal in and out of GTM, and make it accessible in the request response",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "set-up",
    "displayName": "Cookie set-up activation",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "TEXT",
        "name": "cookieName",
        "displayName": "Name of your cookie",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "cookieValue",
        "displayName": "Value of your cookie",
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "config",
    "displayName": "Response configuration",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "TEXT",
        "name": "messageName",
        "displayName": "Name of the message",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "enableInputRequest",
        "checkboxText": "Activate input request in the response ?",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "transformQueryString",
        "checkboxText": "Transform output Query string into an object ?",
        "simpleValueType": true,
        "help": "for GET requests"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const addMessageListener = require('addMessageListener');
const setResponseBody = require('setResponseBody');
const getCookieValues = require('getCookieValues');
const JSON = require('JSON');
const getRequestBody = require('getRequestBody');
const decodeUriComponent = require('decodeUriComponent');
const getRequestQueryParameters = require('getRequestQueryParameters');
const getRequestMethod = require('getRequestMethod');
const logToConsole = require('logToConsole');
const getEventData = require('getEventData');

const enableDebugMode = getCookieValues(data.cookieName)[0] === data.cookieValue;

function collectMessages() {
    const collectedMessages = [];

    if (data.enableInputRequest) {
        const requestBody = getRequestBody();
        const messageContent = {
            trackerName: 'input request',
            requestPayload: requestBody ? JSON.parse(requestBody) : getRequestQueryParameters(),
            statusCode: 200,
            requestType: getRequestMethod(),
        };

        collectedMessages.push({
            content: JSON.stringify(messageContent)
        });
    }

    addMessageListener(data.messageName, (messageType, message) => {
        if (message.requestType === 'GET' && message.requestBody && data.transformQueryString) {
            message.requestBody = queryStringToObject(message.requestBody);
        }

        collectedMessages.push({
            content: JSON.stringify(message)
        });

        setResponseBody(JSON.stringify({
            event_name: getEventData('event_name'),
            data: collectedMessages
        }));
    });
}

function queryStringToObject(queryString) {
    const params = {};
    const pairs = queryString.slice(1).split("&"); 
    for (var i = 0; i < pairs.length; i++) {
        const pair = pairs[i].split("=");
        const key = decodeUriComponent(pair[0]);
        const value = decodeUriComponent(pair[1] || ''); 
        params[key] = value;
    }
    return params;
}

if (enableDebugMode) {
    collectMessages();
    data.gtmOnSuccess();
} else {
    logToConsole('Debug mode disabled');
    data.gtmOnFailure();  
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "use_message",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedActions",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 1/21/2025, 10:26:19 AM


