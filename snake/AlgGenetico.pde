class AlgGenetico
{
  Individuo[] population;
  Individuo atual;
  int generationCount=0;
  int individuoCount=0;
  
  AlgGenetico(int numberPop,int in,int hd, int out)
  {
    population = new Individuo[numberPop];
    for(int i=0;i<numberPop;i++)population[i] = new Individuo(in,hd,out);
  }
  
  
  
}

class Individuo
{
  double[][] inHdWeight;
  double[][] hdOutWeight;
  
  Individuo(int in,int hd, int out)
  {
    inHdWeight = new double[in][hd];
    hdOutWeight = new double[hd][out];
  }
  
  void setRandom()
  {
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)
      inHdWeight[i][j] = random(-1,1);
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)
      hdOutWeight[i][j] = random(-1,1);
  }
  
  Individuo reproduceWith(Individuo ind)
  {
    Individuo novo = new Individuo(inHdWeight.length,hdOutWeight.length,hdOutWeight[0].length);
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)
      novo.inHdWeight[i][j] = (inHdWeight[i][j]+ind.inHdWeight[i][j])/2;
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)
      novo.hdOutWeight[i][j] = (inHdWeight[i][j]+ind.inHdWeight[i][j])/2;
    return novo;  
  }
  
  Individuo mutate(double mutationChance)
  {
    Individuo novo = new Individuo(inHdWeight.length,hdOutWeight.length,hdOutWeight[0].length);
    for(int i=0;i<inHdWeight.length;i++)for(int j=0;j<inHdWeight[i].length;j++)
      if(random(1)<=mutationChance)novo.inHdWeight[i][j] = random(-1,1);
    for(int i=0;i<hdOutWeight.length;i++)for(int j=0;j<hdOutWeight[i].length;j++)
      if(random(1)<=mutationChance)novo.hdOutWeight[i][j] = random(-1,1);
    return novo;
  }
  
  
}
