package graphic;

import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JTextField;

import main.Execution;
import main.Main;
public class Control_panel extends JPanel{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static JTextField grid_size=new JTextField("20");
	private static JTextField rate=new JTextField("1000");
	public static boolean random=false;
	private static JButton start=new JButton("Start");
	private static JButton generate=new JButton("Generate grid");
	private static JButton generate_random=new JButton("Generate random environment");
	
	private static JRadioButton robstacle=new JRadioButton("Modify obstacles");
	private static JRadioButton rgoal=new JRadioButton("Modify goal's position");
	private static JRadioButton rrobot=new JRadioButton("Modify robot position");
	private static Execution current_ex=null;
	public Control_panel(){
		this.setLayout(new GridLayout(3, 1));
		JPanel p1=new JPanel(new FlowLayout());

		p1.add(new JLabel("Size:"));
		
		p1.add(Control_panel.grid_size);
		p1.add(new JLabel("Rate:"));
		p1.add(Control_panel.rate);
		
		Control_panel.grid_size.setPreferredSize(new Dimension(100,30));
		Control_panel.rate.setPreferredSize(new Dimension(100,30));
		
		p1.add(Control_panel.generate);
		p1.add(Control_panel.generate_random);
		this.add(p1);
		p1=new JPanel(new FlowLayout());
		ButtonGroup gr=new ButtonGroup();
		gr.add(Control_panel.robstacle);
		gr.add(Control_panel.rgoal);
		gr.add(Control_panel.rrobot);
		Control_panel.robstacle.setSelected(true);
		p1.add(Control_panel.robstacle);
		p1.add(Control_panel.rgoal);
		p1.add(Control_panel.rrobot);
		this.add(p1);
		p1=new JPanel(new FlowLayout());
		p1.add(Control_panel.start);
		this.add(p1);
		
		this.add_listeners();
	}
	private void add_listeners() {
		Control_panel.generate.addActionListener(new generate_click());
		Control_panel.start.addActionListener(new start_click());
		Control_panel.generate_random.addActionListener(new generate_random_click());
		
		
	}
	
	static boolean  modify_obstacle(){
		return(Control_panel.robstacle.isSelected());
	}
	static boolean  modify_goal(){
		return(Control_panel.rgoal.isSelected());
	}
	static boolean modify_robot(){
		return Control_panel.rrobot.isSelected();
	}
	
	
	private class generate_click implements ActionListener{

		@Override
		public void actionPerformed(ActionEvent e) {
			Control_panel.random=false;
	
			int size;
			try{
			size=Integer.parseInt(Control_panel.grid_size.getText());
			if(size<=0)
				size=20;
			}
			catch( NumberFormatException e1){
				size=20;
			}
			
			Main.init_grid(size);
			
		}
		
	}
	public static Execution getCurrentExecution(){
		return Control_panel.current_ex;
	}
	
	
	public static int getRate(){
		int a=1000;
		String as=Control_panel.rate.getText();
		try{
		a=Integer.parseInt(as);
		}
		catch(NumberFormatException e){
			//Do nothing
		}
		return a;
	}
	private class start_click implements ActionListener{

		@Override
		public void actionPerformed(ActionEvent arg0) {
			Control_panel.current_ex=new Execution();
			
		}
	}
		private class generate_random_click implements ActionListener{

			@Override
			public void actionPerformed(ActionEvent arg0) {
				Control_panel.random=true;
			
				int size;
				try{
				size=Integer.parseInt(Control_panel.grid_size.getText());
				if(size<=0)
					size=20;
				}
				catch( NumberFormatException e1){
					size=20;
				}
				
				Main.init_grid(size);
				
			}
		
	}
}






	
