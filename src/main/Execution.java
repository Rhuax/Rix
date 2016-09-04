package main;

import graphic.Control_panel;





import javax.swing.JOptionPane;

import net.sf.clipsrules.jni.Environment;
import net.sf.clipsrules.jni.FactAddressValue;
import net.sf.clipsrules.jni.MultifieldValue;
import net.sf.clipsrules.jni.PrimitiveValue;

public class Execution extends Thread {
	public static Position robot_position;
	public static Position goal_position;
	public static boolean executing=false;
	public static boolean cont = true;
	private Environment clips;
	
	public Execution() {
		cont=true;
		clips = new Environment();
		Execution.executing=true;
		clips.load("rix2.clp");
		// System.out.println(clips.eval("(rules)").toString());
		clips.reset();
		clips.eval("(bind ?*grid_size* "+Main.grid_size+")");
		clips.eval("(watch activations)");
		assertpos(robot_position, "ME");
		assertpos(goal_position, "GOAL");
		start();
		
	}
	
	public static boolean isExecuting(){
		return Execution.executing;
	}
	@Override
	public void run() {

		while (cont) {
			// Assert obstacles, goal position
			try {
				Thread.sleep(Control_panel.getRate());
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			String facing = null;
			update_obstacles();
			do {
				clips.run(1);
				// Infer till the ES decides where to go
				/*System.out.println("FACTS:");
				clips.eval("(facts)");
				System.out.println("AGENDA:");
				clips.eval("(agenda)");*/
				
				goal_achieved();
				
			} while (((facing = check_go_presence()) == null) && cont==true);
			if (cont == false)
				JOptionPane.showMessageDialog(null, "Goal achieved!");
			else {
				Position old = new Position(robot_position.getX(),
						robot_position.getY());
				this.move(facing);
				Main.update_robot_position(old, robot_position);

				this.reset_go();
			}
		}
		clips.destroy();
		Execution.executing=false;
	}

	private void update_obstacles() {
		clips.eval("(retract_surrounding_obstacles)");
		for(Direction d: Direction.values()){
			if(Main.check_obstacle_presence(d, Execution.robot_position))
				clips.assertString("(obstacle (where "+d+"))");
		}
		
	}

	private void goal_achieved() {
		PrimitiveValue a=null;
		
		try{
		a=clips.eval("(get-all-facts-by-names goal)");
		MultifieldValue v = (MultifieldValue) a;
		
		if (v.size() > 0)
			cont = false;
		}
		catch(Exception e){
		}
	}

	private void move(String facing) {
		switch (facing) {
		case "NORD":
			robot_position.decrementX();
			break;
		case "SUD":
			robot_position.incrementX();
			break;
		case "EST":
			robot_position.incrementY();
			break;
		case "OVEST":
			robot_position.decrementY();
			break;
		}

	}

	private void assertpos(Position p, String ent) {
		int x = p.getX();
		int y = p.getY();
		String a = "(position (entity " + ent + ") (x " + x + ") (y " + y
				+ "))";
		this.clips.assertString(a);

	}

	public void modify_pos(Position p, String ent) {
		clips.eval("(do-for-all-facts ((?f position)) (eq ?f:entity " + ent
				+ ") (modify ?f (x " + p.getX() + ") (y " + p.getY() + ")))");
		
		clips.assertString("("+ent+"_pos_changed)");
	}

	private void reset_go() {
		MultifieldValue v = (MultifieldValue) clips.eval("(get-all-facts-by-names go)");
		FactAddressValue f = (FactAddressValue) v.get(0);
		clips.eval("(retract " + f.getFactIndex() + ")");
	}

	private String check_go_presence() {
		PrimitiveValue a=null;
		String res = null;
		try{
		a= clips.eval("(get-all-facts-by-names go)");
		MultifieldValue v = (MultifieldValue)a;
		
		if (v.size() > 0) {
			FactAddressValue fv = (FactAddressValue) v.get(0);
			try {
				res = fv.getFactSlot("where").toString();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		}
		catch(Exception e){
			
		}
		return res;
	}
	
	public static void main(String... args) {
	
	}
}
