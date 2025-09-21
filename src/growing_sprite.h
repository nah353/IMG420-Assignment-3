#ifndef GROWING_SPRITE_H
#define GROWING_SPRITE_H

#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/core/binder_common.hpp>

using namespace godot;

class GrowingSprite : public Sprite2D {
    GDCLASS(GrowingSprite, Sprite2D)

private:
    double growth_speed;
    double current_scale;
    bool growing;

protected:
    static void _bind_methods();

public:
    GrowingSprite();
    ~GrowingSprite() = default;

    void set_growth_speed(double p_speed);
    double get_growth_speed() const;

    void start_growth();
    void _on_life_added(Node *icon); // signal receiver

    void _ready() override;
    void _process(double delta) override;
};


#endif // GROWING_SPRITE_H
