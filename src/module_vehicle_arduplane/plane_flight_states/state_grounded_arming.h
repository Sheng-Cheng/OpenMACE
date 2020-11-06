#ifndef AP_STATE_GROUNDED_ARMING_H
#define AP_STATE_GROUNDED_ARMING_H


#include "module_vehicle_ardupilot/flight_states/abstract_state_ardupilot.h"

namespace ardupilot {
namespace state{

class AP_State_GroundedIdle;
class AP_State_GroundedArmed;

class AP_State_GroundedArming : public AbstractStateArdupilot
{
public:
    AP_State_GroundedArming();

    virtual ~AP_State_GroundedArming() = default;

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
    bool armingCheck;
};

} //end of namespace ardupilot
} //end of namespace state

#endif // AP_STATE_GROUNDED_ARMING_H