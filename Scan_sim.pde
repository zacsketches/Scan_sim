/*
	This sketch is designed to work out the classes and containers necessary to 
	build a simulator for my 5pt scanner.
*/
class Wedge_point {
	float x, y;
	
	Wedge_point(float _x, float _y) {x=_x; y=_y;}
};

class Scan_wedge {
	int half_width = 20;
	int length = 200;
	
	int heading;
	Wedge_point p1, p2, p3;
	
	Scan_wedge(int _heading) {
		
		int heading = _heading;
		
		float upper = PI * (heading + half_width) / 180;
		float lower = PI * (heading - half_width) / 180;
		
		p1 = new Wedge_point(300, 300);
		p2 = new Wedge_point(300+cos(upper)*length, 300-sin(upper)*length);
		p3 = new Wedge_point(300+cos(lower)*length, 300-sin(lower)*length);
		
		println("upper is: " + str(upper));
		println("lower is: " + str(lower));
	}
		
	void display() {
		fill(128);
		stroke(0);
		ellipse(p1.x, p1.y, 10, 10);
		ellipse(p2.x, p2.y, 10, 10);
		ellipse(p3.x, p3.y, 10, 10);
	}
};

class Sim_scan{
	ArrayList<Scan_wedge> wedges;
	
	Sim_scan() {
		wedges = new ArrayList<Scan_wedge>();
	}
	
	void add(Scan_wedge w) {
		wedges.add(w);
	}
	
	void display() {
		for (int i=0; i<wedges.size(); ++i) {
			Scan_wedge tmp = wedges.get(i);
			tmp.display();
		}
	}
};

Sim_scan scan;

Scan_wedge w1;
Scan_wedge w2;
Scan_wedge w3;

void setup() {
	size(600,600);
	
	scan = new Sim_scan();
	
	w1 = new Scan_wedge(135);
	w2 = new Scan_wedge(90);
	w3 = new Scan_wedge(45);
	
	scan.add(w1);
	scan.add(w2);
	scan.add(w3);
}

void draw() {
	scan.display();
}
