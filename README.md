# Spelt

Matrix defines a set of open APIs for decentralized communication, suitable for
securely publishing, persisting and subscribing to data over a global open
federation of servers with no single point of control. Uses include Instant
Messaging (IM), Voice over IP (VoIP) signalling, Internet of Things (IoT)
communication, and bridging together existing communication silos—providing
the basis of a new, open, real-time communication ecosystem.

Spelt aims to be a server implementation of the Matrix API. The following are
the relevant components of the specification:

* [Matrix client-server
  specification](https://matrix.org/docs/spec/client_server/r0.6.1): provides
  messaging functionality used by Matrix-compliant clients (target version
  0.6.1)

* [Matrix server-server
  specification](https://matrix.org/docs/spec/server_server/r0.1.4.html):
  provides federation amongst servers (target version 0.1.4)

Spelt is implemented in [Elixir](https://elixir-lang.org/) using
[Phoenix](https://www.phoenixframework.org/) as the web app framework and
[Neo4j](https://neo4j.com/) as the database.

This is my first Elixir project and serves as a learning experience, so expect
rough edges and pedantic and non-Elixir-idiomatic code.

## License

Spelt is licensed under the three-clause BSD license. See LICENSE.txt.

## To Do

Spelt is under active development, and much work remains before this becomes a
functioning messaging server.

### Client-Server

This checklist tracks the progress of implementing the endpoints defined in the
client-server spec. 

- [x] 2 API Standards
- [x] 2.1 `GET /_matrix/client/versions`
- [x] 4 Server Discovery
- [x] 4.1 Well-known URI
- [x] 4.1.1 `GET /.well-known/matrix/client`
- [ ] 5 Client Authentication
- [x] 5.5 Login
- [x] 5.5.1 `GET /_matrix/client/r0/login`
- [x] 5.5.2 `POST /_matrix/client/r0/login`
- [x] 5.5.3 `POST /_matrix/client/r0/logout`
- [x] 5.5.4 `POST /_matrix/client/r0/logout/all`
- [ ] 5.6 Account registration and management
- [ ] 5.6.1 `POST /_matrix/client/r0/register`
- [ ] 5.6.2 `POST /_matrix/client/r0/register/email/requestToken`
- [ ] 5.6.3 `POST /_matrix/client/r0/register/msisdn/requestToken`
- [ ] 5.6.4 `POST /_matrix/client/r0/account/password`
- [ ] 5.6.5 `POST /_matrix/client/r0/account/password/email/requestToken`
- [ ] 5.6.6 `POST /_matrix/client/r0/account/password/msisdn/requestToken`
- [ ] 5.6.7 `POST /_matrix/client/r0/account/deactivate`
- [ ] 5.6.8 `GET /_matrix/client/r0/register/available`
- [ ] 5.7 Adding Account Administrative Contact Information
- [ ] 5.7.1 `GET /_matrix/client/r0/account/3pid`
- [ ] 5.7.2 Deprecated: `POST /_matrix/client/r0/account/3pid`
- [ ] 5.7.3 `POST /_matrix/client/r0/account/3pid/add`
- [ ] 5.7.4 `POST /_matrix/client/r0/account/3pid/bind`
- [ ] 5.7.5 `POST /_matrix/client/r0/account/3pid/delete`
- [ ] 5.7.6 `POST /_matrix/client/r0/account/3pid/unbind`
- [ ] 5.7.7 `POST /_matrix/client/r0/account/3pid/email/requestToken`
- [ ] 5.7.8 `POST /_matrix/client/r0/account/3pid/msisdn/requestToken`
- [ ] 5.8 Current account information
- [ ] 5.8.1 `GET /_matrix/client/r0/account/whoami`
- [ ] 6 Capabilities negotiation
- [ ] 6.1 `GET /_matrix/client/r0/capabilities`
- [ ] 8 Filtering
- [ ] 8.2 API endpoints
- [ ] 8.2.1 `POST /_matrix/client/r0/user/{userId}/filter`
- [ ] 8.2.2 `GET /_matrix/client/r0/user/{userId}/filter/{filterId}`
- [ ] 9 Events
- [ ] 9.4 Syncing
- [ ] 9.4.1 `GET /_matrix/client/r0/sync`
- [ ] 9.4.2 Deprecated: `GET /_matrix/client/r0/events`
- [ ] 9.4.3 Deprecated: `GET /_matrix/client/r0/initialSync`
- [ ] 9.4.4 Deprecated: `GET /_matrix/client/r0/events/{eventId}`
- [ ] 9.5 Getting events for a room
- [ ] 9.5.1 `GET /_matrix/client/r0/rooms/{roomId}/event/{eventId}`
- [ ] 9.5.2 `GET /_matrix/client/r0/rooms/{roomId}/state/{eventType}/{stateKey}`
- [ ] 9.5.3 `GET /_matrix/client/r0/rooms/{roomId}/state`
- [ ] 9.5.4 `GET /_matrix/client/r0/rooms/{roomId}/members`
- [ ] 9.5.5 `GET /_matrix/client/r0/rooms/{roomId}/joined_members`
- [ ] 9.5.6 `GET /_matrix/client/r0/rooms/{roomId}/messages`
- [ ] 9.5.7 Deprecated: `GET /_matrix/client/r0/rooms/{roomId}/initialSync`
- [ ] 9.6 Sending events to a room
- [ ] 9.6.1 `PUT /_matrix/client/r0/rooms/{roomId}/state/{eventType}/{stateKey}`
- [ ] 9.6.2 `PUT /_matrix/client/r0/rooms/{roomId}/send/{eventType}/{txnId}`
- [ ] 9.7 Redactions
- [ ] 9.7.2 Client behaviour
- [ ] 9.7.2.1 `PUT /_matrix/client/r0/rooms/{roomId}/redact/{eventId}/{txnId}`
- [ ] 10 Rooms
- [ ] 10.1 Creation
- [ ] 10.1.1 `POST /_matrix/client/r0/createRoom`
- [ ] 10.2 Room aliases
- [ ] 10.2.1 `PUT /_matrix/client/r0/directory/room/{roomAlias}`
- [ ] 10.2.2 `GET /_matrix/client/r0/directory/room/{roomAlias}`
- [ ] 10.2.3 `DELETE /_matrix/client/r0/directory/room/{roomAlias}`
- [ ] 10.2.4 `GET /_matrix/client/r0/rooms/{roomId}/aliases`
- [ ] 10.4 Room membership
- [ ] 10.4.1 `GET /_matrix/client/r0/joined_rooms`
- [ ] 10.4.2 Joining rooms
- [ ] 10.4.2.1 `POST /_matrix/client/r0/rooms/{roomId}/invite`
- [ ] 10.4.2.2 `POST /_matrix/client/r0/rooms/{roomId}/join`
- [ ] 10.4.2.3 `POST /_matrix/client/r0/join/{roomIdOrAlias}`
- [ ] 10.4.3 Leaving rooms
- [ ] 10.4.3.1 `POST /_matrix/client/r0/rooms/{roomId}/leave`
- [ ] 10.4.3.2 `POST /_matrix/client/r0/rooms/{roomId}/forget`
- [ ] 10.4.3.3 `POST /_matrix/client/r0/rooms/{roomId}/kick`
- [ ] 10.4.4 Banning users in a room
- [ ] 10.4.4.1 `POST /_matrix/client/r0/rooms/{roomId}/ban`
- [ ] 10.4.4.2 `POST /_matrix/client/r0/rooms/{roomId}/unban`
- [ ] 10.5 Listing rooms
- [ ] 10.5.1 `GET /_matrix/client/r0/directory/list/room/{roomId}`
- [ ] 10.5.2 `PUT /_matrix/client/r0/directory/list/room/{roomId}`
- [ ] 10.5.3 `GET /_matrix/client/r0/publicRooms`
- [ ] 10.5.4 `POST /_matrix/client/r0/publicRooms`
- [ ] 11 User Data
- [ ] 11.1 User Directory
- [ ] 11.1.1 `POST /_matrix/client/r0/user_directory/search`
- [ ] 11.2 Profiles
- [x] 11.2.1 `PUT /_matrix/client/r0/profile/{userId}/displayname`
- [x] 11.2.2 `GET /_matrix/client/r0/profile/{userId}/displayname`
- [ ] 11.2.3 `PUT /_matrix/client/r0/profile/{userId}/avatar_url`
- [ ] 11.2.4 `GET /_matrix/client/r0/profile/{userId}/avatar_url`
- [ ] 11.2.5 `GET /_matrix/client/r0/profile/{userId}`
- [ ] 13.4 Typing Notifications
- [ ] 13.4.2 Client behaviour
- [ ] 13.4.2.1 `PUT /_matrix/client/r0/rooms/{roomId}/typing/{userId}`
- [ ] 13.5 Receipts
- [ ] 13.5.2 Client behaviour
- [ ] 13.5.2.1 `POST /_matrix/client/r0/rooms/{roomId}/receipt/{receiptType}/{eventId}`
- [ ] 13.6 Fully read markers
- [ ] 13.6.2 Client behaviour
- [ ] 13.6.2.1 `POST /_matrix/client/r0/rooms/{roomId}/read_markers`
- [ ] 13.7 Presence
- [ ] 13.7.2 Client behaviour
- [ ] 13.7.2.1 `PUT /_matrix/client/r0/presence/{userId}/status`
- [ ] 13.7.2.2 `GET /_matrix/client/r0/presence/{userId}/status`
- [ ] 13.8 Content repository
- [ ] 13.8.2 Client behaviour
- [ ] 13.8.2.1 `POST /_matrix/media/r0/upload`
- [ ] 13.8.2.2 `GET /_matrix/media/r0/download/{serverName}/{mediaId}`
- [ ] 13.8.2.3 `GET /_matrix/media/r0/download/{serverName}/{mediaId}/{fileName}`
- [ ] 13.8.2.4 `GET /_matrix/media/r0/thumbnail/{serverName}/{mediaId}`
- [ ] 13.8.2.5 `GET /_matrix/media/r0/preview_url`
- [ ] 13.8.2.6 `GET /_matrix/media/r0/config`
- [ ] 13.9 Send-to-Device messaging
- [ ] 13.9.3 Protocol definitions
- [ ] 13.9.3.1 `PUT /_matrix/client/r0/sendToDevice/{eventType}/{txnId}`
- [ ] 13.10 Device Management
- [ ] 13.10.1 Client behaviour
- [ ] 13.10.1.1 `GET /_matrix/client/r0/devices`
- [ ] 13.10.1.2 `GET /_matrix/client/r0/devices/{deviceId}`
- [ ] 13.10.1.3 `PUT /_matrix/client/r0/devices/{deviceId}`
- [ ] 13.10.1.4 `DELETE /_matrix/client/r0/devices/{deviceId}`
- [ ] 13.10.1.5 `POST /_matrix/client/r0/delete_devices`
- [ ] 13.11 End-to-End Encryption
- [ ] 13.11.5 Protocol definitions
- [ ] 13.11.5.2 Key management API
- [ ] 13.11.5.2.1 `POST /_matrix/client/r0/keys/upload`
- [ ] 13.11.5.2.2 `POST /_matrix/client/r0/keys/query`
- [ ] 13.11.5.2.3 `POST /_matrix/client/r0/keys/claim`
- [ ] 13.11.5.2.4 `GET /_matrix/client/r0/keys/changes`
- [ ] 13.13 Push Notifications
- [ ] 13.13.1 Client behaviour
- [ ] 13.13.1.1 `GET /_matrix/client/r0/pushers`
- [ ] 13.13.1.2 `POST /_matrix/client/r0/pushers/set`
- [ ] 13.13.1.3 Listing Notifications
- [ ] 13.13.1.3.1 `GET /_matrix/client/r0/notifications`
- [ ] 13.13.1.6 Push Rules: API
- [ ] 13.13.1.6.1 `GET /_matrix/client/r0/pushrules/`
- [ ] 13.13.1.6.2 `GET /_matrix/client/r0/pushrules/{scope}/{kind}/{ruleId}`
- [ ] 13.13.1.6.3 `DELETE /_matrix/client/r0/pushrules/{scope}/{kind}/{ruleId}`
- [ ] 13.13.1.6.4 `PUT /_matrix/client/r0/pushrules/{scope}/{kind}/{ruleId}`
- [ ] 13.13.1.6.5 `GET /_matrix/client/r0/pushrules/{scope}/{kind}/{ruleId}/enabled`
- [ ] 13.13.1.6.6 `PUT /_matrix/client/r0/pushrules/{scope}/{kind}/{ruleId}/enabled`
- [ ] 13.13.1.6.7 `GET /_matrix/client/r0/pushrules/{scope}/{kind}/{ruleId}/actions`
- [ ] 13.13.1.6.8 `PUT /_matrix/client/r0/pushrules/{scope}/{kind}/{ruleId}/actions`
- [ ] 13.14 Third party invites
- [ ] 13.14.2 Client behaviour
- [ ] 13.14.2.1 `POST /_matrix/client/r0/rooms/{roomId}/invite`
- [ ] 13.15 Server Side Search
- [ ] 13.15.1 Client behaviour
- [ ] 13.15.1.1 `POST /_matrix/client/r0/search`
- [ ] 13.17 Room Previews
- [ ] 13.17.1 Client behaviour
- [ ] 13.17.1.1 `GET /_matrix/client/r0/events`
- [ ] 13.18 Room Tagging
- [ ] 13.18.2 Client Behaviour
- [ ] 13.18.2.1 `GET /_matrix/client/r0/user/{userId}/rooms/{roomId}/tags`
- [ ] 13.18.2.2 `PUT /_matrix/client/r0/user/{userId}/rooms/{roomId}/tags/{tag}`
- [ ] 13.18.2.3 `DELETE /_matrix/client/r0/user/{userId}/rooms/{roomId}/tags/{tag}`
- [ ] 13.19 Client Config
- [ ] 13.19.2 Client Behaviour
- [ ] 13.19.2.1 `PUT /_matrix/client/r0/user/{userId}/account_data/{type}`
- [ ] 13.19.2.2 `GET /_matrix/client/r0/user/{userId}/account_data/{type}`
- [ ] 13.19.2.3 `PUT /_matrix/client/r0/user/{userId}/rooms/{roomId}/account_data/{type}`
- [ ] 13.19.2.4 `GET /_matrix/client/r0/user/{userId}/rooms/{roomId}/account_data/{type}`
- [ ] 13.20 Server Administration
- [ ] 13.20.1 Client Behaviour
- [ ] 13.20.1.1 `GET /_matrix/client/r0/admin/whois/{userId}`
- [ ] 13.21 Event Context
- [ ] 13.21.1 Client behaviour
- [ ] 13.21.1.1 `GET /_matrix/client/r0/rooms/{roomId}/context/{eventId}`
- [ ] 13.22 SSO client login
- [ ] 13.22.1 Client behaviour
- [ ] 13.22.1.1 `GET /_matrix/client/r0/login/sso/redirect`
- [ ] 13.26 Reporting Content
- [ ] 13.26.1 Client behaviour
- [ ] 13.26.1.1 `POST /_matrix/client/r0/rooms/{roomId}/report/{eventId}`
- [ ] 13.27 Third Party Networks
- [ ] 13.27.1 Third Party Lookups
- [ ] 13.27.1.1 `GET /_matrix/client/r0/thirdparty/protocols`
- [ ] 13.27.1.2 `GET /_matrix/client/r0/thirdparty/protocol/{protocol}`
- [ ] 13.27.1.3 `GET /_matrix/client/r0/thirdparty/location/{protocol}`
- [ ] 13.27.1.4 `GET /_matrix/client/r0/thirdparty/user/{protocol}`
- [ ] 13.27.1.5 `GET /_matrix/client/r0/thirdparty/location`
- [ ] 13.27.1.6 `GET /_matrix/client/r0/thirdparty/user`
- [ ] 13.28 OpenID
- [ ] 13.28.1 `POST /_matrix/client/r0/user/{userId}/openid/request_token`
- [ ] 13.31 Room Upgrades
- [ ] 13.31.2 Client behaviour
- [ ] 13.31.2.1 `POST /_matrix/client/r0/rooms/{roomId}/upgrade`

### Server-Server

The relevant endpoints for implementing the federation specification will
follow eventually.