class Particle{
  float x, y;
  int life;
  
  Particle(){
    x = random(width);
    y = random(height);
    life = (int) random(200);
  }
  
  void updateLocation(float newX, float newY){
    x = newX;
    y = newY;
  }
  
  void decreaseLife(){
    life--;
    if (life == 0){
      life = (int) random(200);
      updateLocation(random(width), random(height));
    }
  }
  
  float getX(){
    return x;
  }
  
  float getY(){
    return y;
  }
}