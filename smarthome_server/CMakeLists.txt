cmake_minimum_required(VERSION 3.10)
project(SmartHomeServer)

set(CMAKE_CXX_STANDARD 17)
# set(SQLITE3_INCLUDE_DIR "C:/sqlite")
# set(SQLITE3_LIBRARY "C:/sqlite/libsqlite3.a")
set(INCLUDE_PATHS
    crow/include
    asio/include
)

# === Headers projet ===
include_directories(include)
find_package(SQLite3 REQUIRED)

# === Code source ===
add_executable(SmartHomeServer
    src/main.cpp
    src/Capteur.cpp
    src/Room.cpp
    src/Maison.cpp
    src/Gestionnaire.cpp
    src/DatabaseManagerSQLite.cpp
    src/Routes.cpp
    src/routes/routes_capteurs.cpp
    src/routes/routes_auth.cpp
    src/routes/routes_historique.cpp
    src/routes/routes_equipements.cpp
)


# === Librairies MySQL ===
target_include_directories(SmartHomeServer PUBLIC ${INCLUDE_PATHS})
target_link_libraries(SmartHomeServer PRIVATE SQLite::SQLite3 ws2_32 mswsock)
