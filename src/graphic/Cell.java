package graphic;

import java.awt.Color;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.swing.BorderFactory;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;

import main.Execution;
import main.Main;
import main.Position;

public class Cell extends JPanel implements MouseListener {
	private Cell_type type;
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private int px, py;
	public Cell(int x, int y) {

		this(Cell_type.Empty, x, y);
	}

	public Cell(Cell_type t, int x, int y) {
		this.setPx(x);
		this.setPy(y);
		this.setBorder(BorderFactory.createLineBorder(Color.black));
		this.setType(t);
		this.addMouseListener(this);

	}

	public void setType(Cell_type c) {
		this.type = c;
		this.removeAll();
		switch (this.type) {
		case Empty:
			this.setBackground(Color.LIGHT_GRAY);
			break;
		case Goal:
			this.setBackground(Color.GREEN);
			break;
		case Obstacle:
			this.setBackground(Color.BLACK);
			break;
		case Robot:
			/*
			JLabel label=new JLabel();
			label.setIcon(new ImageIcon(new ImageIcon("rix.png").getImage().getScaledInstance(this.getWidth(), this.getHeight(), Image.SCALE_DEFAULT)));
			add(label);*/
			this.setBackground(Color.red);
			break;
		
		}
		revalidate();
		repaint();
		//this.repaint();
	}
	
	 
	public Cell_type getType() {
		return type;
	}

	@Override
	public void mouseClicked(MouseEvent e) {

	}

	@Override
	public void mouseEntered(MouseEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void mouseExited(MouseEvent e) {
		// TODO Auto-generated method stub

	}

	@Override
	public void mousePressed(MouseEvent e) {
		if (Control_panel.modify_goal()) {
			if (SwingUtilities.isLeftMouseButton(e)) {
				if (this.getType() == Cell_type.Empty) {
					if (Execution.goal_position != null) {
						int x = Execution.goal_position.getX();
						int y = Execution.goal_position.getY();
						Main.grid[x][y].setType(Cell_type.Empty);
					}
					Execution.goal_position=new Position(this.px, this.py);
					if(Execution.isExecuting())
					Control_panel.getCurrentExecution().modify_pos(Execution.goal_position, "GOAL");
					
					this.setType(Cell_type.Goal);
				}
			}
		} else if (Control_panel.modify_obstacle()) {
			if (SwingUtilities.isLeftMouseButton(e)) {
				if (this.getType() == Cell_type.Empty)
					this.setType(Cell_type.Obstacle);

			} else if (SwingUtilities.isRightMouseButton(e))
				if (this.getType() == Cell_type.Obstacle)
					this.setType(Cell_type.Empty);

		} else if (Control_panel.modify_robot()) {
			if (SwingUtilities.isLeftMouseButton(e)) {
				if (this.getType() == Cell_type.Empty) {
					if (Execution.robot_position != null) {
						int x = Execution.robot_position.getX();
						int y = Execution.robot_position.getY();
						Main.grid[x][y].setType(Cell_type.Empty);
					}
					Execution.robot_position = new Position(this.px, this.py);
					if(Execution.isExecuting())
						Control_panel.getCurrentExecution().modify_pos(Execution.robot_position, "ME");
					this.setType(Cell_type.Robot);
				}
			}
		}
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		// TODO Auto-generated method stub

	}

	public int getPy() {
		return py;
	}

	public void setPy(int py) {
		this.py = py;
	}

	public int getPx() {
		return px;
	}

	public void setPx(int px) {
		this.px = px;
	}
	
	
	
}
