/*
	This sketch is designed to work out the classes and containers necessary to 
	build a simulator for my 5pt scanner.
*/
class Wedge_point {
	float x, y;
	
	Wedge_point(float _x, float _y) {x=_x; y=_y;}
};

class Sim_obs{
	float x, y;
	float v = 1;
	
	Sim_obs(){
		y = 0;
		x = random(150, max_x-150);
	}
	
	void set_velocity(int velocity) { v=velocity; }
	
	void update(){
		y += v;
	}
	
	void display() {
		fill(0);
		stroke(0);
		ellipse(x, y, 10, 10);
	}
};

class Scan_wedge {
	int half_width = 20;
	int length = 300;
	
	int heading;
	Wedge_point p, q, r;
	
	color clear_fill = color(200, 50);
	color obs_fill = color(#00FF00, 50); //light green
	
	//set each update if the wedge contains an obstruction
	boolean obstructed = false;
	int obs_range;
	int max_range = 360;
	
	Scan_wedge(int _heading) {
		
		int heading = _heading;
		
		float upper = PI * (heading + half_width) / 180;
		float lower = PI * (heading - half_width) / 180;
		
		p = new Wedge_point(300, 300);
		q = new Wedge_point(300+cos(upper)*length, 300-sin(upper)*length);
		r = new Wedge_point(300+cos(lower)*length, 300-sin(lower)*length);
		
		println("upper is: " + str(upper));
		println("lower is: " + str(lower));
	}
	
	void clear_obstructed() {
		obstructed = false;
		obs_range = max_range;
	}
	
	int range() { return obs_range; }
	
	//***********************************************************************
	//                    CALCULATE BARYCENTRIC CONTAINMENT
	//
	//  Barycentric coordinates allow expression of the coordinates of any point
	//  as a linear combination of a triangle's vertices.  The physical association
	//  is that you can balance a triangle on any point within its boundary or on
	//  along its edge with three scalar weights at the vertices defined as
	//  a, b, and c such that:
	//      x = a * x1 + b * x2  + c * x3
	//      y = a * y1 + b * y2 + c * y3
	//      a + b + c = 1
	//
	//  Solving these equations for a, b and c yields:
	//     a = ((y2-y3)*(x-x3) + (x3-x2)*(y-y3)) / ((y2-y3)*(x1-x3) + (x3-x2)*(y1-y3))
	//     b = ((y3-y1)*(x-x3) + (x1-x3)*(y-y3)) / ((y2-y3)*(x1-x3) + (x3-x2)*(y1-y3))
	//     c = 1 - a - b
	//
	//  For any balance point along an edge or within the boundary of the triangle
	//  the scalars will be equal to zero or positive numbers.  If a point is 
	//  outside the triangle you would have to apply negative weight, or pull up
	//  on one point of the triangle to get it to balance.  So to find out if a 
	//  point is inside the triangle we apply the property:
	//    K inside T if and only if 0<=a<=1 and 0<=b<=1 and 0<=c<=1
	//***********************************************************************
	void set_obstructed(Sim_obs obs) {
	    float den = (q.y-r.y)*(p.x-r.x) + (r.x-q.x)*(p.y-r.y);
	    float a = ((q.y-r.y)*(obs.x-r.x) + (r.x-q.x)*(obs.y-r.y)) / den;
	    float b = ((r.y-p.y)*(obs.x-r.x) + (p.x-r.x)*(obs.y-r.y)) / den;
	    float c = 1 - a - b;
  
	    boolean obs_in_wedge =  0<=a && a<=1 && 0<=b && b<=1 && 0<=c && c<=1;
		if(!obstructed) {
			obstructed = obs_in_wedge ? true : false;
		}
		if(obstructed) {
			float range_to_obs = dist(300,300,obs.x,obs.y);
			obs_range = int(min(range_to_obs, obs_range));
		}
	}
		
	void display() {
		stroke(0);
		color wedge_fill = obstructed ? obs_fill : clear_fill;
		fill(wedge_fill);
		triangle(p.x, p.y, q.x, q.y, r.x, r.y);
		ellipse(p.x, p.y, 10, 10);
		ellipse(q.x, q.y, 10, 10);
		ellipse(r.x, r.y, 10, 10);
	}
	
};

class Sim_scan{
	ArrayList<Scan_wedge> wedges;
	ArrayList<Sim_obs> obs;
	JSONObject headings;
		
	int headings_size = 5;
	int one_in_x = 250;
	
	Sim_scan() {
		obs = new ArrayList<Sim_obs>();
		wedges = new ArrayList<Scan_wedge>();
		headings = loadJSONObject("headings.json");
	    for(int i=0; i<headings_size; i++) {
	       //load the heading for each value of i and create a wedge
	       String h_tag = "h"+i;
	       int temp_h = headings.getInt(h_tag);
		   wedges.add(new Scan_wedge(temp_h));
	    }			
	}

	void update() {
		//determine whether to spawn a new obstruction
		int dice = int(random(0,one_in_x));
		if (dice == 1) {
			obs.add(new Sim_obs());
		}
		//println(dice);
				
		// update the obstructions then remove any obstruction that 
		// has passed the center point
		for (int i =obs.size()-1; i>=0; --i) {
		  Sim_obs tmp = obs.get(i);
		  tmp.update();
		  if (tmp.y > 300) {
		    obs.remove(i);
		  } else {
  			for (int j=0; j<wedges.size(); ++j) {
  				// for each wedge pass in the tmp_obs and set the obstructed
  				// variable if the obs is inside the wedge.
  				Scan_wedge tmp_wedge = wedges.get(j);
  				tmp_wedge.set_obstructed(tmp);
  			}
		  }
		}
		
	}
	
	void display() {
		//show the wedges
		for (int i=0; i<wedges.size(); ++i) {
			Scan_wedge tmp = wedges.get(i);
			tmp.display();
		}
		//show the obstructions
		for (int i=0; i<obs.size(); ++i) {
			Sim_obs tmp = obs.get(i);
			tmp.display();
		}
		//show the range data
		String scan_msg = "{";
		for (int i=wedges.size()-1; i>=0 ;--i) {
			Scan_wedge tmp = wedges.get(i);
			int range = tmp.range();
			scan_msg += range;
			if(i != 0) {
				scan_msg += ", ";
			}
		}
		scan_msg += "}";
		fill(0);
		text(scan_msg, 20, height-20);
		
		//reset the obstructed value for the next pass
		for (int i=0; i<wedges.size(); ++i) {
			Scan_wedge tmp = wedges.get(i);
			tmp.clear_obstructed();
		}
	}
};


//************************************************************************
//*                         MAIN
//************************************************************************

Sim_scan scan;
int max_x = 600;
int max_y = 600;

void setup() {
	size(max_x, max_y);
	
	scan = new Sim_scan();
}

void draw() {
	background(255);
	scan.update();
	scan.display();
}
