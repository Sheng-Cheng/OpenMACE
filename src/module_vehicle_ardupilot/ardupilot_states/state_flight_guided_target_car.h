#ifndef STATE_FLIGHT_GUIDED_TARGET_CAR_H
#define STATE_FLIGHT_GUIDED_TARGET_CAR_H

#include <iostream>
#include <mavlink.h>

#include "data/timer.h"

#include "abstract_state_ardupilot.h"

#include "../guided_timeout_controller.h"

#include "module_vehicle_MAVLINK/controllers/controller_guided_target_item_local.h"

#include "data_generic_command_item/command_item_components.h"

#include "data_generic_mission_item_topic/mission_item_reached_topic.h"


namespace ardupilot{
namespace state{

class State_FlightGuided_CarTarget : public AbstractStateArdupilot
{
public:
    State_FlightGuided_CarTarget();

    void OnExit() override;

public:
    AbstractStateArdupilot* getClone() const override;

    void getClone(AbstractStateArdupilot** state) const override;

public:
    hsm::Transition GetTransition() override;

public:
    bool handleCommand(const std::shared_ptr<AbstractCommandItem> command) override;

    void Update() override;

    void OnEnter() override;

    void OnEnter(const std::shared_ptr<AbstractCommandItem> command) override;

private:
    static void retransmitGuidedCommand(void *p, command_item::Action_DynamicTarget &target)
    {
        static_cast<State_FlightGuided_CarTarget*>(p)->constructAndSendTarget(target);
    }

    void constructAndSendTarget(const command_item::Action_DynamicTarget &command)
    {
        MavlinkEntityKey sender = 255;
        static_cast<MAVLINKUXVControllers::ControllerGuidedTargetItem_Local*>(Owner().ControllersCollection()->At("CartesianTargetController"))->Broadcast(command, sender);
    }

private:
    ardupilot_vehicle::GuidedTimeoutController m_TimeoutController;
};

} //end of namespace state
} //end of namespace arudpilot

#endif // STATE_FLIGHT_GUIDED_TARGET_CAR_H
