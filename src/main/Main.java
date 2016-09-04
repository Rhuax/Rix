package main;

import graphic.Cell;
import graphic.Cell_type;
import graphic.Control_panel;

import java.awt.Color;
import java.awt.Container;
import java.awt.GridLayout;

import javax.swing.BorderFactory;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.WindowConstants;

public class Main {
	public static JPanel sx;
	public static Control_panel dx;
	public static Cell[][] grid;
	public static Container c;
	public static JFrame f;
	public static int grid_size;

	public static void main(String... args) {

		f = new JFrame();
		f.setTitle("Rix!");
		f.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
		c = f.getContentPane();

		c.setLayout(new GridLayout(1, 2));
		sx = new JPanel();
		sx.setBorder(BorderFactory.createLineBorder(Color.black));

		c.add(sx);
		dx = new Control_panel();
		c.add(dx);
		f.setSize(700, 400);
		f.setVisible(true);
	}

	public static void update_robot_position(Position old, Position new_p) {
		int x = old.getX();
		int y = old.getY();
		grid[x][y].setType(Cell_type.Empty);
		x = new_p.getX();
		y = new_p.getY();
		grid[x][y].setType(Cell_type.Robot);

	}

	public static void init_grid(int size) {
		Main.grid_size = size;
		Main.grid = new Cell[size][size];
		Main.sx.removeAll();
		Main.sx.setLayout(new GridLayout(size, size));
		for (int i = 0; i < size; i++)
			for (int j = 0; j < size; j++) {
				Main.grid[i][j] = new Cell(i, j);
				if(Control_panel.random){
					if(Math.random()>0.75)
					Main.grid[i][j].setType(Cell_type.Obstacle);
				}
			}
		for (int i = 0; i < size; i++)
			for (int j = 0; j < size; j++)
				Main.sx.add(Main.grid[i][j]);
		
		
		
		Main.graphic_update();

	}

	private static void graphic_update() {
		Main.sx.revalidate();
		Main.sx.repaint();
	}
	
	private static Cell_type getCellStatus(Position p){
		int x=p.getX();
		int y=p.getY();
		if(x<0 || y<0 || x>=Main.grid_size || y>=Main.grid_size)
			return Cell_type.Obstacle;
		else
			return Main.grid[x][y].getType();
	}
	
	public static boolean check_obstacle_presence(Direction d,Position p){
		Position obstacle=null;
		switch(d){
		case NORD:
			obstacle=new Position(p.getX()-1,p.getY());
			break;
		case SUD:
			obstacle=new Position(p.getX()+1,p.getY());
			break;
		case EST:
			obstacle=new Position(p.getX(),p.getY()+1);
			break;
		case OVEST:
			obstacle=new Position(p.getX(),p.getY()-1);
			break;
		}
		return(getCellStatus(obstacle)==Cell_type.Obstacle);
		
		
	}
}
