#include "pulsing_sprite.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void PulsingSprite::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_boosting", "active"), &PulsingSprite::set_boosting);
    ClassDB::bind_method(D_METHOD("set_pulse_speed", "speed"), &PulsingSprite::set_pulse_speed);
    ClassDB::bind_method(D_METHOD("get_pulse_speed"), &PulsingSprite::get_pulse_speed);
	ClassDB::bind_method(D_METHOD("set_fade_out_multiplier", "multiplier"), &PulsingSprite::set_fade_out_multiplier);
	ClassDB::bind_method(D_METHOD("get_fade_out_multiplier"), &PulsingSprite::get_fade_out_multiplier);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT,
        "pulse_speed",
        PROPERTY_HINT_RANGE,
        "0.1,10.0,0.1"),
        "set_pulse_speed",
        "get_pulse_speed");

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT,
        "fade_out_multiplier",
        PROPERTY_HINT_RANGE,
        "0.1,10.0,0.1"),
        "set_fade_out_multiplier",
        "get_fade_out_multiplier");

    // Signal emitter
    ADD_SIGNAL(MethodInfo("pulse_complete"));

    // Signal receiver
    ClassDB::bind_method(D_METHOD("_on_player_boosting_changed", "active"),
        &PulsingSprite::_on_player_boosting_changed);
}

PulsingSprite::PulsingSprite() {
    reveal_ratio = 0.0;
    pulse_speed = 1.0;
    fade_out_multiplier = 1.5;
    boosting = false;
    set_process(true);
}

void PulsingSprite::_ready() {
    set_region_enabled(true);
    set_region_rect(Rect2(0, 0, get_texture()->get_width(), 0)); // start hidden from top
    set_modulate(Color(1, 1, 1, 1));
    set_centered(false); // make growth start from top left corner
}

void PulsingSprite::set_pulse_speed(double p_speed) {
    pulse_speed = p_speed;
}
double PulsingSprite::get_pulse_speed() const {
    return pulse_speed;
}

void PulsingSprite::set_fade_out_multiplier(double mult) {
    fade_out_multiplier = mult;
}
double PulsingSprite::get_fade_out_multiplier() const {
    return fade_out_multiplier;
}

void PulsingSprite::_on_player_boosting_changed(bool active) {
    set_boosting(active);
}

void PulsingSprite::set_boosting(bool active) {
    boosting = active;
}

void PulsingSprite::_process(double delta) {
    // Update reveal ratio toward target based on boosting state
    double target = boosting ? 1.0 : 0.0;
    double dir = (target > reveal_ratio) ? 1.0 : -1.0;
    double speed = pulse_speed;

    if (reveal_ratio != target) {
		// Adjust speed when fading out
        if (dir < 0)
        {
			speed *= fade_out_multiplier;
        }
        
        reveal_ratio += dir * speed * delta;
        if ((dir > 0 && reveal_ratio >= target) ||
            (dir < 0 && reveal_ratio <= target)) {
            reveal_ratio = target;
            // Emit signal when fully revealed
            if (target == 1.0)
                emit_signal("pulse_complete");
        }

        // Adjust positioning of sprite
        Ref<Texture2D> tex = get_texture();
        if (tex.is_valid()) {
            const double tex_h = tex->get_height();
            const double vis_h = tex_h * reveal_ratio;
            set_region_rect(Rect2(0, 0, tex->get_width(), vis_h));
        }
    }
}
