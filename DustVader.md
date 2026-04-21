Sets:



🧭 Navigation / Movement



TARGET\_POINT              → target\_point

GO\_HOME                   → go\_home

STOP                      → stop

ABORT                     → abort

CONTINUE                  → continue





🧹 Cleaning actions



CLEAN\_ALL                 → clean\_all

CLEAN\_CONTINUE            → clean\_continue

CLEAN\_SPOT                → clean\_spot

CLEAN\_AREA                → clean\_area

CLEAN\_MAP                 → clean\_map

CLEAN\_START\_OR\_CONTINUE   → clean\_start\_or\_continue





🗺️ Mapping / Exploration



EXPLORE                   → explore

START\_SCAN                → start\_scan

SAVE\_MAP                  → save\_map

REVERT\_MAP                → revert\_map

MODIFY\_MAP                → modify\_map

DELETE\_MAP                → delete\_map

SET\_MAIN\_MAP              → main\_map\_id





🏠 Areas (rooms / zones)



ADD\_AREA                  → add\_area

MODIFY\_AREA               → modify\_area

MERGE\_AREAS               → merge\_areas

SPLIT\_AREA                → split\_area

DELETE\_AREA               → delete\_area





🚫 No-go zones



PROPOSE\_NO\_GO\_AREAS       → propose\_nogo\_areas

CONFIRM\_NO\_GO\_AREAS       → confirm\_nogo\_areas





⏰ Scheduling



ADD\_SCHEDULED\_TASK        → add\_scheduled\_task

MODIFY\_SCHEDULED\_TASK     → modify\_scheduled\_task

DELETE\_SCHEDULED\_TASK     → delete\_scheduled\_task

CLEAR\_SCHEDULE            → clear\_schedule





⚙️ Settings / Config



TIME                      → time

TIME\_ZONE                 → timezone

ROBOT\_NAME                → robot\_name

SWITCH\_CLEANING\_PARAMETER\_SET → switch\_cleaning\_parameter\_set

PUMP\_VOLUME\_SETTINGS      → pump\_volume\_settings

LIVE\_PARAMETERS           → live\_parameters





📶 Connectivity / Pairing



CONNECT\_WIFI              → connect\_wifi

FINALIZE\_PAIRING          → pairing\_done





🔄 System / Maintenance



DO\_FACTORY\_RESET          → do\_factory\_reset

DO\_STATISTICS\_RESET       → do\_statistics\_reset









Gets

public enum SDKGetRequestType implements SDKRequestType {

&#x20;   STATUS("status"),

&#x20;   PROTOCOL\_VERSION("protocol\_version"),

&#x20;   WIFI\_STATUS("wifi\_status"),

&#x20;   COMMAND\_RESULT("command\_result"),

&#x20;   FEATURE\_MAP("feature\_map"),

&#x20;   N\_N\_POLYGONS("n\_n\_polygons"),

&#x20;   ROB\_POSE("rob\_pose"),

&#x20;   CLEANING\_GRID\_MAP("cleaning\_grid\_map"),

&#x20;   AREAS("areas"),

&#x20;   ROBOT\_NAME("robot\_name"),

&#x20;   SCHEDULE("schedule"),

&#x20;   MAP\_STATUS("map\_status"),

&#x20;   CUSTOM\_VALUE("custom\_value"),

&#x20;   TILE\_MAP("tile\_map"),

&#x20;   TOPO\_MAP("topo\_map"),

&#x20;   WIFI\_SCAN\_RESULTS("wifi\_scan\_results"),

&#x20;   CLEANING\_PARAMETER\_SET("cleaning\_parameter\_set"),

&#x20;   PUMP\_VOLUME\_SETTINGS("pump\_volume\_settings"),

&#x20;   ROBOT\_ID("robot\_id"),

&#x20;   MAPS("maps"),

&#x20;   EVENT\_LOG("event\_log"),

&#x20;   STATISTICS("statistics"),

&#x20;   PERMANENT\_STATISTICS("permanent\_statistics"),

&#x20;   PRODUCT\_FEATURE\_SET("product\_feature\_set"),

&#x20;   NETWORK\_STATUS("network\_status"),

&#x20;   BUG\_REPORT("bug\_report"),

&#x20;   SEEN\_POLYGON("seen\_polygon"),

&#x20;   UI\_CMD\_LOG("ui\_cmd\_log"),

&#x20;   EXECUTION\_STATE("execution\_state"),

&#x20;   TASK\_HISTORY("task\_history"),

&#x20;   FETCH\_JOURNAL("journal"),

&#x20;   TIME\_ZONE("timezone"),

&#x20;   MAIN\_MAP\_ID("main\_map\_id"),

&#x20;   ROBOT\_FLAGS("robot\_flags"),

&#x20;   LIVE\_PARAMETERS("live\_parameters"),

&#x20;   AREA\_HISTORY("area\_history"),

&#x20;   ALL\_AREA\_HISTORY("all\_area\_histories");



