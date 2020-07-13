#include "macetogui.h"


MACEtoGUI::MACEtoGUI() :
    m_sendAddress(QHostAddress::LocalHost),
    m_sendPort(1234),
    m_positionTimeoutOccured(false),
    m_attitudeTimeoutOccured(false),
    m_modeTimeoutOccured(false),
    m_fuelTimeoutOccured(false)
{
}

MACEtoGUI::MACEtoGUI(const QHostAddress &sendAddress, const int &sendPort) :
    m_sendAddress(sendAddress),
    m_sendPort(sendPort),
    m_positionTimeoutOccured(false),
    m_attitudeTimeoutOccured(false),
    m_modeTimeoutOccured(false),
    m_fuelTimeoutOccured(false)
{
}

MACEtoGUI::~MACEtoGUI() {

}

//!
//! \brief setSendAddress Set the TCP send address for MACE-to-GUI comms
//! \param sendAddress TCP send address
//!
void MACEtoGUI::setSendAddress(const QHostAddress &sendAddress) {
    m_sendAddress = sendAddress;
}

//!
//! \brief setSendPort Set the TCP send port for MACE-to-GUI comms
//! \param sendPort TCP send port
//!
void MACEtoGUI::setSendPort(const int &sendPort) {
    m_sendPort = sendPort;
}

//!
//! \brief setPositionTimeout Set position timeout flag
//! \param flag Boolean denoting if timer has fired (true) or not (false)
//!
void MACEtoGUI::setPositionTimeout(const bool &flag) {
    m_positionTimeoutOccured = flag;
}

//!
//! \brief setAttitudeTimeout Set attitude timeout flag
//! \param flag Boolean denoting if timer has fired (true) or not (false)
//!
void MACEtoGUI::setAttitudeTimeout(const bool &flag) {
    m_attitudeTimeoutOccured = flag;
}

//!
//! \brief setFuelTimeout Set fuel timeout flag
//! \param flag Boolean denoting if timer has fired (true) or not (false)
//!
void MACEtoGUI::setFuelTimeout(const bool &flag) {
    m_fuelTimeoutOccured = flag;
}

//!
//! \brief setModeTimeout Set mode timeout flag
//! \param flag Boolean denoting if timer has fired (true) or not (false)
//!
void MACEtoGUI::setModeTimeout(const bool &flag) {
    m_modeTimeoutOccured = flag;
}

//!
//! \brief sendCurrentMissionItem Send vehicle mission to the MACE GUI
//! \param vehicleID Vehicle ID with the new vehicle mission
//! \param component Vehicle mission component
//!
void MACEtoGUI::sendCurrentMissionItem(const int &vehicleID, const std::shared_ptr<MissionTopic::MissionItemCurrentTopic> &component) {
    UNUSED(vehicleID);

    QJsonDocument doc(component->toJSON(static_cast<int>(component->getMissionKey().m_systemID),"CurrentMissionItem"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write current mission item failed..." << std::endl;
    }
}

//!
//! \brief sendVehicleTarget Send current vehicle target to the MACE GUI
//! \param vehicleID Vehicle ID with the new vehicle target
//! \param component Vehicle target component
//!
void MACEtoGUI::sendVehicleTarget(const int &vehicleID, const Abstract_GeodeticPosition* targetPosition) {
    
    QJsonDocument doc(targetPosition->toJSON(vehicleID, "CurrentVehicleTarget"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write global origin failed..." << std::endl;
    }
}

//!
//! \brief sendVehicleHome Send new vehicle home to the MACE GUI
//! \param vehicleID Vehicle ID with the new vehicle home available
//! \param home New vehicle home
//!
void MACEtoGUI::sendVehicleHome(const int &vehicleID, const command_item::SpatialHome &home)
{
    if(home.getPosition()->getCoordinateSystemType() == CoordinateSystemTypes::GEODETIC)
    {
        QJsonDocument doc(home.toJSON(vehicleID,"VehicleHome"));
        bool bytesWritten = writeTCPData(doc.toJson());

        if(!bytesWritten){
            std::cout << "Write Home position failed..." << std::endl;
        }
    }

}

//!
//! \brief MACEtoGUI::sendGlobalOrigin Send new global origin to the MACE GUI
//! \param origin New global origin
//!
void MACEtoGUI::sendGlobalOrigin(const command_item::SpatialHome &origin)
{
    
    if(origin.getPosition()->getCoordinateSystemType() == CoordinateSystemTypes::GEODETIC)
    {
        QJsonDocument doc(origin.toJSON(0,"GlobalOrigin"));
        bool bytesWritten = writeTCPData(doc.toJson());

        if(!bytesWritten){
            std::cout << "Write global origin failed..." << std::endl;
        }
    }
}

//!
//! \brief sendPositionData Send vehicle position data to the MACE GUI
//! \param vehicleID Vehicle ID with new position update
//! \param component Global position component
//!
void MACEtoGUI::sendPositionData(const int &vehicleID, const std::shared_ptr<mace::pose_topics::Topic_GeodeticPosition> &component)
{
    if(component->getPositionObj()->getCoordinateSystemType() == CoordinateSystemTypes::GEODETIC)
    {

        QJsonDocument doc(component->toJSON(vehicleID,"vehicle_position"));
        if(m_positionTimeoutOccured)
        {
            bool bytesWritten = writeTCPData(doc.toJson());

            if(!bytesWritten){
                std::cout << "Write Position Data failed..." << std::endl;
            }

            // Reset timeout:
            m_positionTimeoutOccured = false;
        }
    }
}

//!
//! \brief sendAttitudeData Send vehicle attitude data to the MACE GUI
//! \param vehicleID Vehicle ID with new attitude update
//! \param component Vehicle attitude component
//!
void MACEtoGUI::sendAttitudeData(const int &vehicleID, const std::shared_ptr<mace::pose_topics::Topic_AgentOrientation> &component)
{
    QJsonDocument doc(component->toJSON(vehicleID,"vehicle_attitude"));
    if(m_attitudeTimeoutOccured)
    {
        bool bytesWritten = writeTCPData(doc.toJson());

        if(!bytesWritten){
            std::cout << "Write Attitude Data failed..." << std::endl;
        }

        // Reset timeout:
        m_attitudeTimeoutOccured = false;
    }
}

//!
//! \brief sendVehicleAirspeed Send vehicle airspeed to the MACE GUI
//! \param vehicleID Vehicle ID with the new airspeed
//! \param component Vehicle airspeed component
//!
void MACEtoGUI::sendVehicleAirspeed(const int &vehicleID, const mace::measurement_topics::Topic_AirSpeedPtr &component)
{
        QJsonDocument doc(component->toJSON(vehicleID,"vehicle_airspeed"));
        bool bytesWritten = writeTCPData(doc.toJson());

        if(!bytesWritten){
            std::cout << "Write vehicle airspeed Data failed..." << std::endl;
        }
}

//!
//! \brief sendVehicleFuel Send vehicle fuel data to the MACE GUI
//! \param vehicleID Vehicle ID with the new fuel update
//! \param component Vehicle battery component
//!
void MACEtoGUI::sendVehicleFuel(const int &vehicleID, const std::shared_ptr<DataGenericItemTopic::DataGenericItemTopic_Battery> &component)
{

    QJsonDocument doc(component->toJSON(vehicleID,"vehicle_fuel"));
    if(m_fuelTimeoutOccured)
    {
        bool bytesWritten = writeTCPData(doc.toJson());

        if(!bytesWritten){
            std::cout << "Write Fuel Data failed..." << std::endl;
        }

        // Reset timeout:
        m_fuelTimeoutOccured = false;
    }
}

//!
//! \brief sendVehicleMode Send vehilce mode data to the MACE GUI
//! \param vehicleID Vehicle ID with the new flight mode update
//! \param component Vehicle flight mode component
//!
void MACEtoGUI::sendVehicleMode(const int &vehicleID, const std::shared_ptr<DataGenericItemTopic::DataGenericItemTopic_FlightMode> &component)
{
    QJsonDocument doc(component->toJSON(vehicleID,"vehicle_mode"));
    if(m_modeTimeoutOccured)
    {
        bool bytesWritten = writeTCPData(doc.toJson());

        if(!bytesWritten){
            std::cout << "Write Vehicle Mode Data failed..." << std::endl;
        }

        // Reset timeout:
        m_modeTimeoutOccured = false;
    }
}

//!
//! \brief sendVehicleText Send vehicle message data to the MACE GUI
//! \param vehicleID Vehicle ID with the new message
//! \param component Vehicle text component
//!
void MACEtoGUI::sendVehicleText(const int &vehicleID, const std::shared_ptr<DataGenericItemTopic::DataGenericItemTopic_Text> &component)
{
    QJsonDocument doc(component->toJSON(vehicleID,"vehicle_text"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write Vehicle Text Data failed..." << std::endl;
    }
}

//!
//! \brief sendVehicleGPS Send vehicle GPS status to the MACE GUI
//! \param vehicleID Vehicle ID with the new GPS status
//! \param component GPS status component
//!
void MACEtoGUI::sendVehicleGPS(const int &vehicleID, const std::shared_ptr<DataGenericItemTopic::DataGenericItemTopic_GPS> &component)
{
    QJsonDocument doc(component->toJSON(vehicleID,"vehicle_gps"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write Vehicle GPS Data failed..." << std::endl;
    }
}

//!
//! \brief sendVehicleArm Send vehicle arm status to the MACE GUI
//! \param vehicleID Vehicle ID with the new ARM status
//! \param component Vehicle Arm component
//!
void MACEtoGUI::sendVehicleArm(const int &vehicleID, const std::shared_ptr<DataGenericItemTopic::DataGenericItemTopic_SystemArm> &component)
{
    QJsonDocument doc(component->toJSON(vehicleID,"vehicle_arm"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write vehicle arm failed..." << std::endl;
    }
}

//!
//! \brief sendMissionItemReached Send mission item reached topic to the MACE GUI
//! \param vehicleID Vehicle ID corresponding to the vehicle who reached a mission item
//! \param component Mission item reached component
//!
void MACEtoGUI::sendMissionItemReached(const int &vehicleID, const std::shared_ptr<MissionTopic::MissionItemReachedTopic> &component)
{
    QJsonDocument doc(component->toJSON(vehicleID,"MissionItemReached"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write mission item reached failed..." << std::endl;
    }
}

//!
//! \brief sendVehicleHeartbeat Send vehicle heartbeat to the MACE GUI
//! \param vehicleID Vehicle ID with the new vehicle heartbeat
//! \param component Vehicle heartbeat component
//!
void MACEtoGUI::sendVehicleHeartbeat(const int &vehicleID, const std::shared_ptr<DataGenericItem::DataGenericItem_Heartbeat> &component)
{
    QJsonDocument doc(component->toJSON(vehicleID,"vehicle_heartbeat"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write vehicle heartbeat failed..." << std::endl;
    }
}

//!
//! \brief sendVehicleMission Send vehicle mission data to the MACE GUI
//! \param vehicleID Vehicle ID with the new mission available
//! \param missionList Mission list component
//!
void MACEtoGUI::sendVehicleMission(const int &vehicleID, const MissionItem::MissionList &missionList)
{
    QJsonDocument doc(missionList.toJSON(vehicleID,"VehicleMission"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write Vehicle Mission Data failed..." << std::endl;
    }
}

//!
//! \brief sendSensorFootprint Send vehicle sensor footprint to the MACE GUI
//! \param vehicleID Vehicle ID with the new sensor footprint available
//! \param component Vehicle sensor footprint component
//!
void MACEtoGUI::sendSensorFootprint(const int &vehicleID, const std::shared_ptr<DataVehicleSensors::SensorVertices_Global> &component) {
   
    QJsonDocument doc(component->toJSON(vehicleID,"SensorFootprint"));
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write vehicle sensor footprint failed..." << std::endl;
    }
}

//!
//! \brief sendEnvironmentVertices Send environment boundary vertices to the MACE GUI
//! \param component Environment boundary component
//!
void MACEtoGUI::sendEnvironmentVertices(const std::vector<mace::pose::GeodeticPosition_3D> &component) {

    QJsonObject json;
    json["message_type"] = "EnvironmentBoundary";
    json["agentID"] = 0;

    QJsonArray verticies;
    for(auto&& vertex : component) {
        QJsonObject obj;
        obj["lat"] = vertex.getLatitude();
        obj["lng"] = vertex.getLongitude();
        obj["alt"] = vertex.getAltitude();

        verticies.push_back(obj);
    }

    json["environmentBoundary"] = verticies;

    QJsonDocument doc(json);
    bool bytesWritten = writeTCPData(doc.toJson());

    if(!bytesWritten){
        std::cout << "Write environment boundary failed..." << std::endl;
    }
}

//!
//! \brief writeTCPData Write data to the MACE GUI via TCP
//! \param data Data to be sent to the MACE GUI
//! \return True: success / False: failure
//!
bool MACEtoGUI::writeTCPData(QByteArray data)
{
    std::shared_ptr<QTcpSocket> tcpSocket = std::make_shared<QTcpSocket>();
    tcpSocket->connectToHost(m_sendAddress, static_cast<quint16>(m_sendPort));
    tcpSocket->waitForConnected();
    if(tcpSocket->state() == QAbstractSocket::ConnectedState)
    {
        tcpSocket->write(data); //write the data itself
        tcpSocket->flush();
        tcpSocket->waitForBytesWritten();
        return true;
    }
    else
    {
        std::cout << "TCP socket not connected MACE TO GUI" << std::endl;
        tcpSocket->close();
        return false;
    }
}
