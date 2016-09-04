package main;

public class Position {
	private int x, y;

	public Position(int x, int y) {
		this.setX(x);
		this.setY(y);
	}

	public int getX() {
		return x;
	}

	public void setX(int x) {
		this.x = x;
	}

	public int getY() {
		return y;
	}

	public void setY(int y) {
		this.y = y;
	}

	public void incrementY() {
		this.y++;
	}

	public void incrementX() {
		this.x++;
	}

	public void decrementY() {
		this.y--;
	}

	public void decrementX() {
		this.x--;
	}

}
