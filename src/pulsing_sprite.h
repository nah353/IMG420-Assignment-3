#ifndef PULSING_SPRITE_H
#define PULSING_SPRITE_H

#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class PulsingSprite : public Sprite2D {
    GDCLASS(PulsingSprite, Sprite2D)

private:
    double reveal_ratio;
    double pulse_speed;
    double fade_out_multiplier;
    bool   boosting;

protected:
    static void _bind_methods();

public:
    PulsingSprite();
    ~PulsingSprite() = default;

    void _ready() override;
    void _process(double delta) override;

    // Called by other existing script via signals
    void set_boosting(bool active);
    void _on_player_boosting_changed(bool active);

    // Properties for Inspector
    void set_pulse_speed(double p_speed);
    double get_pulse_speed() const;

    void set_fade_out_multiplier(double mult);
    double get_fade_out_multiplier() const;
};

#endif // PULSING_SPRITE_H
