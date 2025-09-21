#include "growing_sprite.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GrowingSprite::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_growth_speed", "speed"), &GrowingSprite::set_growth_speed);
    ClassDB::bind_method(D_METHOD("get_growth_speed"), &GrowingSprite::get_growth_speed);
    ClassDB::bind_method(D_METHOD("start_growth"), &GrowingSprite::start_growth);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT,
        "growth_speed",
        PROPERTY_HINT_RANGE,
        "0.1,10.0,0.1"),
        "set_growth_speed",
        "get_growth_speed");

    ADD_SIGNAL(MethodInfo("growth_complete"));

	ClassDB::bind_method(D_METHOD("_on_life_added", "icon"), &GrowingSprite::_on_life_added);
}

GrowingSprite::GrowingSprite() {
    growth_speed = 1.0;
    current_scale = 0.0;
    growing = false;
    set_process(true);
}

void GrowingSprite::_ready() {
    set_visible(false);
    set_scale(Vector2(0.0, 0.0)); // start hidden and collapsed
}

void GrowingSprite::set_growth_speed(double p_speed) {
    growth_speed = p_speed;
}
double GrowingSprite::get_growth_speed() const {
    return growth_speed;
}

void GrowingSprite::_on_life_added(Node* icon) {
    if (icon != this) {
        start_growth();
    }
}

void GrowingSprite::start_growth() {
    current_scale = 0.0;
    growing = true;
    set_visible(true);
    set_scale(Vector2(0.0, 0.0));
}

void GrowingSprite::_process(double delta) {
    if (!growing) {
        return;
    }

    current_scale += growth_speed * delta;
    if (current_scale >= 1.0) {
        current_scale = 1.0;
        growing = false;
        emit_signal("growth_complete");
    }

    set_scale(Vector2(current_scale, current_scale));
}
