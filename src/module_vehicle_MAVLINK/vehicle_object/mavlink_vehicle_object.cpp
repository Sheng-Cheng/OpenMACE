#include "mavlink_vehicle_object.h"


MavlinkVehicleObject::MavlinkVehicleObject(CommsMAVLINK *commsObj, const MaceCore::ModuleCharacteristic &module, const int &m_MavlinkID):
    m_CB(nullptr), m_module(module), mavlinkID(m_MavlinkID)
{
    this->commsLink = commsObj;

    controllerQueue = new TransmitQueue(2000, 3);
    state = new StateData_MAVLINK();
    mission = new MissionData_MAVLINK();
}

MavlinkVehicleObject::~MavlinkVehicleObject()
{ 
    delete state;
    delete mission;
}

int MavlinkVehicleObject::getMAVLINKID() const
{
    return this->mavlinkID;
}


MaceCore::ModuleCharacteristic MavlinkVehicleObject::getModule() const
{
    return m_module;
}

CommsMAVLINK* MavlinkVehicleObject::getCommsObject() const
{
    return this->commsLink;
}

bool MavlinkVehicleObject::handleMAVLINKMessage(const mavlink_message_t &msg)
{
    return m_ControllersCollection.Receive(msg, msg.sysid);
}
